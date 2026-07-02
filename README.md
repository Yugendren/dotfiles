# dotfiles

My personal dev environment — zsh, tmux, Neovim (LazyVim), Starship, Ghostty, and friends.
Managed with [GNU Stow](https://www.gnu.org/software/stow/); tools installed via a Homebrew `Brewfile`.

## What's here

| Package    | Links to                     | Notes |
|------------|------------------------------|-------|
| `zsh`      | `~/.zshrc`, `~/.zprofile`    | Oh My Zsh + Starship. OS-guarded (macOS vs WSL). |
| `tmux`     | `~/.tmux/.tmux.conf.local`   | Customization for [oh-my-tmux](https://github.com/gpakosz/.tmux) (framework cloned by installer). |
| `nvim`     | `~/.config/nvim`             | [LazyVim](https://www.lazyvim.org/) config + `lazy-lock.json` (pinned plugins). |
| `starship` | `~/.config/starship.toml`    | |
| `ghostty`  | `~/.config/ghostty/config`   | **macOS only** (see WSL note below). |
| `bat`      | `~/.config/bat/`             | Catppuccin Mocha theme. |
| `git`      | `~/.gitconfig`, `~/.config/git/ignore` | delta pager. |

## Install (macOS or Linux/WSL)

```sh
git clone https://github.com/Yugendren/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh
```

The installer is idempotent: it installs Homebrew (if missing), runs the `Brewfile`,
installs Oh My Zsh + third-party zsh plugins, clones oh-my-tmux, and stows everything.
Existing real files are backed up to `*.pre-dotfiles.bak` before symlinking.

Then: `chsh -s "$(command -v zsh)"` (if zsh isn't your default shell) and open a new terminal.

## Windows (WSL) notes

Everything that runs *inside* WSL — zsh, tmux, Neovim, Starship — works identically to macOS.
Two things differ:

1. **The terminal is on the Windows side.** WSL doesn't run Ghostty; use **Windows Terminal**
   (or WezTerm). The `ghostty` package is skipped automatically on non-macOS. Configure your
   Windows terminal's font/colors there — a matching Catppuccin Mocha scheme is easy to find.
2. **Install the Nerd Font on Windows**, not in WSL, or icons render as boxes. Download
   *CaskaydiaCove Nerd Font* from [nerdfonts.com](https://www.nerdfonts.com/font-downloads),
   install it in Windows, and select it in your terminal's settings.

Recommended WSL base: Ubuntu. Run `./install.sh` inside it — linuxbrew is installed and used
automatically.

## Managing later

```sh
stow --restow --target="$HOME" zsh   # re-link one package after editing
stow --delete --target="$HOME" zsh   # unlink a package
```

Edit files in `~/dotfiles/<package>/…`; the symlinks mean changes are live immediately.
