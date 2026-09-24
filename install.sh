#!/usr/bin/env bash
# Bootstrap these dotfiles on a fresh machine (macOS or Linux/WSL).
# Idempotent — safe to re-run.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES"

info() { printf '\033[1;36m==>\033[0m %s\n' "$*"; }

# --- 1. Homebrew ---------------------------------------------------------
if ! command -v brew >/dev/null 2>&1; then
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
# Load brew into this shell (covers macOS + linuxbrew paths)
for p in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
  [[ -x "$p" ]] && eval "$("$p" shellenv)" && break
done

# --- 2. Packages ---------------------------------------------------------
info "Installing packages from Brewfile..."
brew bundle --file="$DOTFILES/Brewfile"

# On Debian/Ubuntu the bat binary may be named batcat; expose it as `bat`.
if ! command -v bat >/dev/null 2>&1 && command -v batcat >/dev/null 2>&1; then
  mkdir -p "$HOME/.local/bin"
  ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
fi

# --- 3. GNU stow ---------------------------------------------------------
command -v stow >/dev/null 2>&1 || brew install stow

# --- 4. Oh My Zsh + third-party plugins ---------------------------------
export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
if [[ ! -d "$ZSH" ]]; then
  info "Installing Oh My Zsh..."
  RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH/custom}"
clone_plugin() { # repo, dest
  local dest="$ZSH_CUSTOM/plugins/$2"
  [[ -d "$dest" ]] || git clone --depth=1 "$1" "$dest"
}
info "Installing zsh plugins..."
clone_plugin https://github.com/zsh-users/zsh-autosuggestions           zsh-autosuggestions
clone_plugin https://github.com/zsh-users/zsh-syntax-highlighting        zsh-syntax-highlighting
clone_plugin https://github.com/zsh-users/zsh-completions                zsh-completions
clone_plugin https://github.com/zsh-users/zsh-history-substring-search   zsh-history-substring-search
clone_plugin https://github.com/Aloxaf/fzf-tab                           fzf-tab
clone_plugin https://github.com/MichaelAquilina/zsh-you-should-use       you-should-use

# --- 5. oh-my-tmux -------------------------------------------------------
# We version only .tmux.conf.local; the framework itself is cloned here.
if [[ ! -e "$HOME/.tmux/.tmux.conf" ]]; then
  info "Installing oh-my-tmux..."
  git clone --depth=1 https://github.com/gpakosz/.tmux.git "$HOME/.tmux"
  ln -sf "$HOME/.tmux/.tmux.conf" "$HOME/.tmux.conf"
fi
# TPM — needed for tmux-resurrect / tmux-continuum declared in .tmux.conf.local
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
  info "Installing tmux plugin manager..."
  git clone --depth=1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

# --- 6. Stow all packages ------------------------------------------------
info "Symlinking dotfiles with stow..."
# --adopt would pull existing files in; we back them up instead, then restow.
for pkg in zsh tmux nvim starship ghostty bat git; do
  # ghostty is macOS-only
  if [[ "$pkg" == "ghostty" && "$(uname)" != "Darwin" ]]; then
    info "Skipping ghostty (macOS-only terminal)."
    continue
  fi
  stow --restow --target="$HOME" "$pkg" 2>/dev/null || {
    info "Conflicts in '$pkg' — backing up existing files and retrying..."
    while IFS= read -r f; do
      [[ -e "$HOME/$f" && ! -L "$HOME/$f" ]] && mv "$HOME/$f" "$HOME/$f.pre-dotfiles.bak"
    done < <(cd "$pkg" && find . -type f | sed 's|^\./||')
    stow --restow --target="$HOME" "$pkg"
  }
done

# --- 7. Machine-local secrets file --------------------------------------
if [[ ! -f "$HOME/.zshrc.local" ]]; then
  cat > "$HOME/.zshrc.local" <<'LOCAL'
# Machine-local zsh config — sourced at the end of ~/.zshrc, never committed.
# Put API keys and per-machine tweaks here, e.g.:
# export DEEPSEEK_API_KEY="..."
LOCAL
  info "Created ~/.zshrc.local — add your API keys there."
fi

# Install tmux plugins non-interactively
[[ -x "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]] && "$HOME/.tmux/plugins/tpm/bin/install_plugins" >/dev/null 2>&1 || true

# --- 8. Post-install -----------------------------------------------------
# Build bat's cache so the custom Catppuccin theme is available.
command -v bat >/dev/null 2>&1 && bat cache --build || true

# Make zsh the default shell if it isn't.
if [[ "$SHELL" != *zsh ]]; then
  info "Set zsh as your default shell with:  chsh -s \"\$(command -v zsh)\""
fi

info "Done. Open a new terminal (or run: exec zsh)."
info "In nvim, plugins install automatically on first launch (LazyVim)."
