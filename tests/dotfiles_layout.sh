#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

required_paths=(
  "$root/bootstrap.sh"
  "$root/install.sh"
  "$root/Makefile"
  "$root/system/packages.apt"
  "$root/nvim/.config/nvim/init.lua"
  "$root/zsh/.zshrc"
  "$root/zsh/.config/zsh/aliases.zsh"
  "$root/zsh/.config/zsh/functions.zsh"
  "$root/zsh/.config/zsh/path.zsh"
  "$root/zsh/.config/zsh/plugins.zsh"
  "$root/git/.gitconfig"
  "$root/git/.config/git/ignore"
  "$root/alacritty/.config/alacritty/alacritty.toml"
  "$root/tmux/.tmux.conf"
  "$root/scripts/.local/bin/dotfiles-doctor"
)

for path in "${required_paths[@]}"; do
  if [[ ! -e "$path" ]]; then
    printf 'missing required path: %s\n' "$path" >&2
    exit 1
  fi
done

if command -v rg >/dev/null 2>&1; then
  if rg -n 'user\.emai' "$root/git" "$root/zsh" "$root/system" "$root/scripts" "$root/alacritty" "$root/tmux" "$root/README.md"; then
    exit 1
  fi
else
  if grep -R -n 'user\.emai' "$root/git" "$root/zsh" "$root/system" "$root/scripts" "$root/alacritty" "$root/tmux" "$root/README.md"; then
    exit 1
  fi
fi

bash -n "$root/bootstrap.sh"
bash -n "$root/install.sh"
bash -n "$root/scripts/.local/bin/dotfiles-doctor"
