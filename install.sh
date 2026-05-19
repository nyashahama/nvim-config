#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
default_packages=(zsh bash git ghostty starship tmux scripts vscode mise ssh templates)

usage() {
	cat <<'USAGE'
Usage:
  ./install.sh --dry-run [package...]
  ./install.sh --apply [package...]

Packages:
  nvim zsh bash git ghostty starship alacritty tmux scripts vscode mise ssh templates

The default package set excludes nvim and the legacy Alacritty package. Move or
clone the repo to ~/.dotfiles before stowing nvim.
USAGE
}

mode="${1:---dry-run}"
case "$mode" in
--dry-run | --apply)
	shift || true
	;;
-h | --help)
	usage
	exit 0
	;;
*)
	usage >&2
	exit 2
	;;
esac

if ! command -v stow >/dev/null 2>&1; then
	echo "GNU Stow is not installed. Run ./bootstrap.sh --install first." >&2
	exit 1
fi

packages=("$@")
if [[ ${#packages[@]} -eq 0 ]]; then
	packages=("${default_packages[@]}")
fi

repo_real="$(realpath "$root")"
nvim_real="$(realpath "$HOME/.config/nvim" 2>/dev/null || true)"
if [[ " ${packages[*]} " == *" nvim "* && "$repo_real" == "$nvim_real" ]]; then
	echo "Refusing to stow nvim while this repo is the live ~/.config/nvim directory." >&2
	echo "Move or clone the repo to ~/.dotfiles, then run ./install.sh --apply nvim." >&2
	exit 1
fi

stow_args=(--target="$HOME" --dir="$root" --no-folding --verbose)
if [[ "$mode" == "--dry-run" ]]; then
	stow_args+=(--simulate)
fi

stow "${stow_args[@]}" "${packages[@]}"
