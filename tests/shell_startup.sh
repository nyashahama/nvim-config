#!/usr/bin/env bash
set -euo pipefail

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

zsh -i -c exit >"$tmpdir/zsh.out" 2>"$tmpdir/zsh.err"
if [[ -s "$tmpdir/zsh.err" ]]; then
	printf 'zsh startup wrote stderr:\n' >&2
	cat "$tmpdir/zsh.err" >&2
	exit 1
fi

if [[ -x "$HOME/.fzf/bin/fzf" || -x "$HOME/.local/share/nvim/lazy/fzf/bin/fzf" || -n "$(command -v fzf || true)" ]]; then
	script -qfec 'zsh -i -c "bindkey \"^R\""' /dev/null >"$tmpdir/zsh-ctrl-r.out" 2>"$tmpdir/zsh-ctrl-r.err"
	if [[ -s "$tmpdir/zsh-ctrl-r.err" ]]; then
		printf 'zsh Ctrl-R binding check wrote stderr:\n' >&2
		cat "$tmpdir/zsh-ctrl-r.err" >&2
		exit 1
	fi

	if ! grep -q 'fzf-history-widget' "$tmpdir/zsh-ctrl-r.out"; then
		printf 'zsh Ctrl-R did not bind to fzf history search:\n' >&2
		cat "$tmpdir/zsh-ctrl-r.out" >&2
		exit 1
	fi
fi

if [[ -r "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" || -r /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh || -r /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
	script -qfec 'zsh -i -c "(( \$+widgets[autosuggest-accept] )) && print autosuggestions-loaded || print autosuggestions-missing"' /dev/null >"$tmpdir/zsh-autosuggest.out" 2>"$tmpdir/zsh-autosuggest.err"
	if [[ -s "$tmpdir/zsh-autosuggest.err" ]]; then
		printf 'zsh autosuggestion check wrote stderr:\n' >&2
		cat "$tmpdir/zsh-autosuggest.err" >&2
		exit 1
	fi

	if ! grep -q 'autosuggestions-loaded' "$tmpdir/zsh-autosuggest.out"; then
		printf 'zsh autosuggestions were not loaded:\n' >&2
		cat "$tmpdir/zsh-autosuggest.out" >&2
		exit 1
	fi
fi

bash -i -c 'printf "%s\n" "$TERMINAL"' >"$tmpdir/bash.out" 2>"$tmpdir/bash.err"
grep -v \
	-e 'cannot set terminal process group' \
	-e 'no job control in this shell' \
	"$tmpdir/bash.err" >"$tmpdir/bash.filtered" || true
if [[ -s "$tmpdir/bash.filtered" ]]; then
	printf 'bash startup wrote unexpected stderr:\n' >&2
	cat "$tmpdir/bash.filtered" >&2
	exit 1
fi

if [[ "$(cat "$tmpdir/bash.out")" != "ghostty" ]]; then
	printf 'bash did not inherit TERMINAL=ghostty\n' >&2
	cat "$tmpdir/bash.out" >&2
	exit 1
fi
