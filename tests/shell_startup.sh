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
