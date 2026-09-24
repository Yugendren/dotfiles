# Homebrew — works on macOS (Apple Silicon / Intel) and Linux (WSL) linuxbrew
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"          # macOS Apple Silicon
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"             # macOS Intel
elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"  # Linux / WSL
fi

export PATH="$HOME/.local/bin:$PATH"
[[ -d "$HOME/.elan/bin" ]] && export PATH="$HOME/.elan/bin:$PATH"   # Lean toolchain, if installed
