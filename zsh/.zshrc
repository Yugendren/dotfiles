# Path to Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Theme - disabled since we use Starship
ZSH_THEME=""

# Plugin configuration
HYPHEN_INSENSITIVE="true"
COMPLETION_WAITING_DOTS="true"
HIST_STAMPS="yyyy-mm-dd"

# Plugins
# Built-in: git, python, pip, brew, macos, extract, sudo, z, fzf, common-aliases, jsontools, aliases, copypath
# Third-party: zsh-autosuggestions, zsh-syntax-highlighting, zsh-completions, you-should-use, zsh-history-substring-search, fzf-tab
plugins=(
  # -- Git & Version Control --
  git
  gitignore

  # -- Python / Data Science --
  python
  pip
  virtualenv

  # -- System & Productivity --
  brew
  sudo
  z
  fzf
  extract
  copypath
  copyfile
  common-aliases
  aliases
  jsontools
  web-search
  colored-man-pages
  thefuck

  # -- Third-party plugins --
  fzf-tab
  zsh-completions
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-history-substring-search
  you-should-use
)

# macOS-only Oh My Zsh plugin (adds `ofd`, `pfd`, `showfiles`, etc.)
[[ "$OSTYPE" == darwin* ]] && plugins+=(macos)

# Load completions
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src

source $ZSH/oh-my-zsh.sh

# ---- User Configuration ----

# Starship prompt (overrides OMZ theme)
eval "$(starship init zsh)"

# Colors
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

# PATH
export PATH="$HOME/.local/bin:$PATH"

# ---- Modern CLI Tool Replacements ----

# bat: better cat with syntax highlighting (Catppuccin theme)
# Note: on Debian/Ubuntu (WSL) the binary is `batcat`; install.sh symlinks it to `bat`.
export BAT_THEME="Catppuccin Mocha"
alias cat="bat --paging=never"
alias catp="bat"

# eza: better ls with icons and colors
alias ls="eza --icons --group-directories-first"
alias ll="eza -la --icons --group-directories-first --git"
alias la="eza -a --icons --group-directories-first"
alias lt="eza --tree --level=2 --icons"
alias llt="eza --tree --level=3 -la --icons"

# dust: better du
alias du="dust"

# duf: better df
alias df="duf"

# procs: better ps
alias ps="procs"

# zoxide: smarter cd (z command already from OMZ, this is the upgrade)
eval "$(zoxide init zsh --cmd cd)"

# thefuck: auto-correct previous command (type "fuck" to fix)
eval $(thefuck --alias)

# lazygit
alias lg="lazygit"

# btop: better top
alias top="btop"

# ---- Aliases ----
alias anime-next="anime"

# Quick navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# Git shortcuts (supplement OMZ git plugin)
alias gs="git status"
alias gd="git diff"
alias glog="git log --oneline --graph --decorate -20"

# Python / Data Science
alias py="python3"
alias ipy="ipython"
alias jn="jupyter notebook"
alias jl="jupyter lab"
alias venv="python3 -m venv .venv && source .venv/bin/activate"
alias activate="source .venv/bin/activate"

# CSV / Data tools
alias csv="csvlens"                    # quick interactive CSV viewer
alias vd="visidata"                    # full spreadsheet TUI (sort, filter, plot, pivot)
alias mlr="mlr --icsv --opprint"       # CSV to pretty-printed table

# ---- VM / SSH Workflow ----
# ssh + auto-attach tmux in one command
# Usage: vm athena  → ssh into athena and attach/create tmux session
vm() {
  TERM=xterm-256color ssh -t "$1" "tmux new-session -A -s main"
}

# mosh + tmux (survives WiFi drops, sleep/wake, network changes)
# Usage: mvm athena  → mosh into athena and attach/create tmux session
mvm() {
  TERM=xterm-256color mosh "$1" -- tmux new-session -A -s main
}

# ---- History Configuration ----
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS

# History substring search keybindings (up/down arrow)
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
