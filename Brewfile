# Brewfile — install with `brew bundle --file=Brewfile`
# Works on macOS and Linux (WSL) linuxbrew. Curated to the tools these dotfiles use.

# ---- Shell / prompt ----
brew "starship"          # prompt
brew "zoxide"            # smarter cd
brew "thefuck"           # command autocorrect
brew "fzf"               # fuzzy finder
brew "fd"                # better find (used by fzf/telescope)
brew "ripgrep"           # fast grep (used by nvim/telescope)

# ---- Modern CLI replacements (referenced by .zshrc aliases) ----
brew "bat"               # cat
brew "eza"               # ls
brew "dust"              # du
brew "duf"               # df
brew "procs"             # ps
brew "btop"              # top
brew "git-delta"         # git pager (delta)
brew "lazygit"           # git TUI (lg)
brew "glow"              # markdown viewer
brew "tldr"              # concise man pages

# ---- Editor / multiplexer ----
brew "neovim"
brew "tmux"

# ---- Data tools (referenced by .zshrc aliases) ----
brew "csvlens"
brew "miller"            # mlr
brew "visidata"          # vd

# ---- macOS-only ----
# Ghostty terminal + Nerd Font. On WSL the terminal lives on the Windows side
# (Windows Terminal), so install the font on Windows manually — see README.
if OS.mac?
  cask "ghostty"
  cask "font-caskaydia-cove-nerd-font"
end
