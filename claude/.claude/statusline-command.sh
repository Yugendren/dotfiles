#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract key information
model=$(echo "$input" | jq -r '.model.display_name // "Claude"')
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
session_name=$(echo "$input" | jq -r '.session_name // empty')
output_style=$(echo "$input" | jq -r '.output_style.name // empty')
vim_mode=$(echo "$input" | jq -r '.vim.mode // empty')
agent_name=$(echo "$input" | jq -r '.agent.name // empty')
transcript_path=$(echo "$input" | jq -r '.transcript_path // empty')
cost_total=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')

# Context window fields (default to 0 so the segment always renders, even pre-first-message)
context_remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // 100')
context_used=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
total_input_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
context_window_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')

# Rate limit fields (only present for Claude.ai subscribers; default to 0 so the segment always renders)
rl_five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // 0')
rl_five_resets_at=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
rl_seven_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // 0')

# Color codes
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD_CYAN='\033[1;36m'
MAGENTA='\033[0;35m'
GRAY='\033[0;90m'
RESET='\033[0m'

parts=()

# Agent name
if [ -n "$agent_name" ]; then
  parts+=("$(printf "${MAGENTA}[agent: %s]${RESET}" "$agent_name")")
fi

# Model name
parts+=("$(printf "${BLUE}%s${RESET}" "$model")")

# Session name
if [ -n "$session_name" ]; then
  parts+=("$(printf "${CYAN}[%s]${RESET}" "$session_name")")
fi

# Current directory (full path, bold cyan — matches Starship config:
# format = "$directory", [directory] style = "bold cyan", truncation_length = 0,
# truncate_to_repo = false). Home dir is shown as ~ to match Starship's default.
cwd_display="${cwd/#$HOME/~}"
parts+=("$(printf "${BOLD_CYAN}%s${RESET}" "$cwd_display")")

# Git branch + status
if [ -d "$cwd/.git" ] || git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    git_status=$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)
    if [ -z "$git_status" ]; then
      parts+=("$(printf "${GREEN}git:(%s)${RESET}" "$branch")")
    else
      modified=$(echo "$git_status" | grep -c '^ M' || true)
      added=$(echo "$git_status" | grep -c '^A' || true)
      untracked=$(echo "$git_status" | grep -c '^??' || true)
      status_info=""
      [ "$modified" -gt 0 ] && status_info="${status_info}~${modified}"
      [ "$added" -gt 0 ] && status_info="${status_info}+${added}"
      [ "$untracked" -gt 0 ] && status_info="${status_info}?${untracked}"
      parts+=("$(printf "${YELLOW}git:(%s%s)${RESET}" "$branch" "$status_info")")
    fi
  fi
fi

# Python venv
if [ -n "$VIRTUAL_ENV" ]; then
  venv_name=$(basename "$VIRTUAL_ENV")
  parts+=("$(printf "${CYAN}venv:(%s)${RESET}" "$venv_name")")
fi

# Context window: tokens used + percentage (color-coded by remaining)
# Always shown — reads as "ctx:0/1M (0% used)" before the first API call.
used_int=$(printf "%.0f" "$context_used" 2>/dev/null || echo "0")
remaining_int=$(printf "%.0f" "$context_remaining" 2>/dev/null || echo "100")

if [ "$remaining_int" -gt 50 ] 2>/dev/null; then
  ctx_color=$GREEN
elif [ "$remaining_int" -gt 20 ] 2>/dev/null; then
  ctx_color=$YELLOW
else
  ctx_color=$RED
fi

# Format token count as human-readable (e.g. 45.2k or 1.2M)
if [ "$total_input_tokens" -ge 1000000 ] 2>/dev/null; then
  tok_display=$(awk "BEGIN { printf \"%.1fM\", $total_input_tokens/1000000 }")
elif [ "$total_input_tokens" -ge 1000 ] 2>/dev/null; then
  tok_display=$(awk "BEGIN { printf \"%.1fk\", $total_input_tokens/1000 }")
else
  tok_display="${total_input_tokens}"
fi

# Format context window size
if [ -n "$context_window_size" ] && [ "$context_window_size" -ge 1000000 ] 2>/dev/null; then
  win_display=$(awk "BEGIN { printf \"%.0fM\", $context_window_size/1000000 }")
elif [ -n "$context_window_size" ] && [ "$context_window_size" -ge 1000 ] 2>/dev/null; then
  win_display=$(awk "BEGIN { printf \"%.0fk\", $context_window_size/1000 }")
else
  win_display="${context_window_size:-?}"
fi

parts+=("$(printf "${ctx_color}ctx:%s/%s (%s%% used)${RESET}" "$tok_display" "$win_display" "$used_int")")

# Session cost: prefer the stdin .cost.total_cost_usd field; fall back to transcript. Always shown.
cost_usd="$cost_total"
if [ -z "$cost_usd" ] || [ "$cost_usd" = "0" ]; then
  if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
    # Fallback: extract cost from the transcript JSONL (costUSD per message)
    fallback_cost=$(grep -o '"costUSD":[0-9.]*' "$transcript_path" 2>/dev/null | tail -1 | grep -o '[0-9.]*$')
    [ -n "$fallback_cost" ] && cost_usd="$fallback_cost"
  fi
fi
[ -z "$cost_usd" ] && cost_usd="0"
cost_display=$(awk "BEGIN { printf \"\$%.4f\", $cost_usd }")
parts+=("$(printf "${GRAY}cost:%s${RESET}" "$cost_display")")

# Fresh tokens ingested this session (input+output+cache-writes across every turn in the
# transcript). Deliberately excludes cache_read_input_tokens: with prompt caching, every turn
# re-reads the whole growing history from cache, so including reads would sum the same context
# over and over and balloon into a huge, misleading number. This is genuinely new content only —
# distinct from ctx, which reflects the *current* context window fill, not a cumulative total.
# Dedupe by message id first: each assistant message can appear as several JSONL lines
# (one per content block) all carrying the same usage object.
session_tokens=0
if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
  session_tokens=$(jq -s '
    [.[] | select(.message.usage != null) | {id: .message.id, u: .message.usage}]
    | unique_by(.id)
    | map((.u.input_tokens // 0) + (.u.output_tokens // 0) + (.u.cache_creation_input_tokens // 0))
    | add // 0
  ' "$transcript_path" 2>/dev/null)
  [ -z "$session_tokens" ] && session_tokens=0
fi

if [ "$session_tokens" -ge 1000000 ] 2>/dev/null; then
  tok_total_display=$(awk "BEGIN { printf \"%.1fM\", $session_tokens/1000000 }")
elif [ "$session_tokens" -ge 1000 ] 2>/dev/null; then
  tok_total_display=$(awk "BEGIN { printf \"%.1fk\", $session_tokens/1000 }")
else
  tok_total_display="${session_tokens}"
fi
parts+=("$(printf "${GRAY}tok:%s${RESET}" "$tok_total_display")")

# Rate limits (Claude.ai subscribers only). Always shown when the fields are present in the
# payload at all; reads as "5h:0%" before any usage. Shows 5-hour % + reset countdown, plus 7-day %.
rl_five_int=$(printf "%.0f" "$rl_five_pct" 2>/dev/null || echo "0")

hours_str=""
if [ -n "$rl_five_resets_at" ]; then
  now=$(date +%s)
  secs_left=$((rl_five_resets_at - now))
  if [ "$secs_left" -gt 0 ] 2>/dev/null; then
    hours_left=$(awk "BEGIN { printf \"%.1f\", $secs_left/3600 }")
    hours_str=" rst:${hours_left}h"
  fi
fi

if [ "$rl_five_int" -lt 50 ] 2>/dev/null; then
  rl_color=$GREEN
elif [ "$rl_five_int" -lt 80 ] 2>/dev/null; then
  rl_color=$YELLOW
else
  rl_color=$RED
fi

rl_seven_int=$(printf "%.0f" "$rl_seven_pct" 2>/dev/null || echo "0")
rl_label="5h:${rl_five_int}%${hours_str} 7d:${rl_seven_int}%"

parts+=("$(printf "${rl_color}%s${RESET}" "$rl_label")")

# Output style
if [ -n "$output_style" ] && [ "$output_style" != "default" ]; then
  parts+=("$(printf "${GRAY}style:%s${RESET}" "$output_style")")
fi

# Vim mode
if [ -n "$vim_mode" ]; then
  if [ "$vim_mode" = "NORMAL" ]; then
    parts+=("$(printf "${YELLOW}[%s]${RESET}" "$vim_mode")")
  else
    parts+=("$(printf "${GRAY}[%s]${RESET}" "$vim_mode")")
  fi
fi

# Join with separator
separator=" $(printf "${GRAY}|${RESET}") "
output=""
for i in "${!parts[@]}"; do
  if [ "$i" -gt 0 ]; then
    output="${output}${separator}"
  fi
  output="${output}${parts[$i]}"
done

printf "%b\n" "$output"
