#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

repo="$tmpdir/repo"
mkdir -p "$repo"
git -C "$repo" init >/dev/null

DEV_TEMPLATES_DIR="$root/templates/.local/share/dev-templates" \
	"$root/scripts/.local/bin/dev-init" "$repo" >/tmp/dev-init.out

for file in .editorconfig .envrc .pre-commit-config.yaml mise.toml justfile; do
	if [[ ! -f "$repo/$file" ]]; then
		printf 'dev-init did not create %s\n' "$file" >&2
		exit 1
	fi
done

printf 'local-value\n' >"$repo/.editorconfig"
if DEV_TEMPLATES_DIR="$root/templates/.local/share/dev-templates" \
	"$root/scripts/.local/bin/dev-init" "$repo" >/tmp/dev-init-overwrite.out 2>/tmp/dev-init-overwrite.err; then
	printf 'dev-init overwrote files without --force\n' >&2
	exit 1
fi

grep -F 'already exists' /tmp/dev-init-overwrite.err >/dev/null
grep -Fx 'local-value' "$repo/.editorconfig" >/dev/null

DEV_TEMPLATES_DIR="$root/templates/.local/share/dev-templates" \
	"$root/scripts/.local/bin/dev-init" --force "$repo" >/tmp/dev-init-force.out

if grep -Fx 'local-value' "$repo/.editorconfig" >/dev/null; then
	printf 'dev-init --force did not replace .editorconfig\n' >&2
	exit 1
fi
