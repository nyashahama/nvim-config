# Dotfiles

Personal dotfiles for an Ubuntu-based development workstation. The repository
lives at `~/.dotfiles`, uses a Stow-compatible package layout, and keeps each
tool's config in the same shape it will have under `$HOME`.

`~/.config/nvim` currently points at the Neovim package inside this repo so the
editor keeps working before GNU Stow is installed.

---

## Layout

| Path | Purpose |
|------|---------|
| `nvim/` | Neovim package; links back to the current single-source config |
| `zsh/` | zsh startup, path, aliases, functions, completion/tool hooks |
| `git/` | global Git config and ignore file |
| `alacritty/` | terminal emulator config |
| `tmux/` | tmux session/workspace config |
| `scripts/` | personal commands installed into `~/.local/bin` |
| `system/` | Ubuntu package list for workstation bootstrap |
| `tests/` | smoke tests for dotfiles and Neovim |
| `docs/nvim.md` | detailed Neovim usage notes |

---

## First Run

Check what the bootstrap would install:

```bash
./bootstrap.sh --check
```

Install base workstation tools:

```bash
./bootstrap.sh --install
```

Run repo checks:

```bash
make test
./scripts/.local/bin/dotfiles-doctor
```

Preview symlinks without changing the machine:

```bash
./install.sh --dry-run
```

Apply non-Neovim packages:

```bash
./install.sh --apply zsh git alacritty tmux scripts
```

---

## Neovim

The local Neovim config is available through this symlink:

```text
~/.config/nvim -> ~/.dotfiles/nvim/.config/nvim
```

The default install excludes `nvim` because this link already exists. If you want
GNU Stow to recreate it later, confirm the link target, remove only the symlink,
then stow the package:

```bash
readlink ~/.config/nvim
unlink ~/.config/nvim
./install.sh --dry-run nvim
./install.sh --apply nvim
```

---

## Packages

The package names match the top-level directories:

```bash
./install.sh --dry-run nvim zsh git alacritty tmux scripts
./install.sh --apply zsh git alacritty tmux scripts
```

`system/` is documentation for packages, not a Stow package.

---

## Private Config

Do not commit secrets or machine-only overrides. Keep private files in:

```text
~/.zshrc.local
~/.gitconfig.local
.env
.env.*
```

The repo intentionally ignores `.claude/`, local env files, backups, and temp
files.

---

## Useful Commands

```bash
make test       # layout + Neovim smoke checks
make doctor     # report installed/missing workstation tools
make check      # bootstrap check + doctor + tests
make bootstrap  # install Ubuntu packages
make dry-run    # preview Stow operations
make install    # apply default Stow packages
```
