#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ ! -x "$root/scripts/.local/bin/dev-perf" ]]; then
	printf 'missing executable dev-perf script\n' >&2
	exit 1
fi

"$root/scripts/.local/bin/dev-perf" --check >/tmp/dev-perf-check.out
grep -F 'zsh startup' /tmp/dev-perf-check.out >/dev/null
grep -F 'neovim startup' /tmp/dev-perf-check.out >/dev/null

for tool in psql redis-cli sqlite3; do
	if ! command -v "$tool" >/dev/null 2>&1; then
		printf 'missing database CLI: %s\n' "$tool" >&2
		exit 1
	fi
done

if command -v code >/dev/null 2>&1 && code --list-extensions | grep -Eiq '^github\.copilot'; then
	printf 'Copilot extension is installed but Neovim-first setup should keep it absent\n' >&2
	exit 1
fi

nvim --headless -u NONE -l "$root/tests/smoke.lua"
