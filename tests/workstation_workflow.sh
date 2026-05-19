#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
home_token='~'

for script in dev-backup dev-fonts dev-gh dev-signing-doctor; do
	if [[ ! -x "$root/scripts/.local/bin/$script" ]]; then
		printf 'missing executable script: %s\n' "$script" >&2
		exit 1
	fi
	bash -n "$root/scripts/.local/bin/$script"
done

if [[ ! -f "$root/git/.config/git/commit-template" ]]; then
	printf 'missing commit template\n' >&2
	exit 1
fi

git config --file "$root/git/.gitconfig" --get commit.template | grep -Fx "$home_token/.config/git/commit-template" >/dev/null
git config --file "$root/git/.gitconfig" --get commit.verbose | grep -Fx 'true' >/dev/null

"$root/scripts/.local/bin/dev-backup" --check >/tmp/dev-backup-check.out
grep -F 'would create' /tmp/dev-backup-check.out >/dev/null
grep -F '.ssh/config' /tmp/dev-backup-check.out >/dev/null

"$root/scripts/.local/bin/dev-gh" aliases --check >/tmp/dev-gh-aliases.out
grep -F 'gh alias set pr-status' /tmp/dev-gh-aliases.out >/dev/null
grep -F 'gh alias set pr-checks' /tmp/dev-gh-aliases.out >/dev/null

"$root/scripts/.local/bin/dev-fonts" --check >/tmp/dev-fonts.out
grep -F 'Font/theme layer' /tmp/dev-fonts.out >/dev/null

ghostty +validate-config --config-file="$root/ghostty/.config/ghostty/config" >/dev/null

"$root/scripts/.local/bin/dev-signing-doctor" --check >/tmp/dev-signing-doctor.out
grep -F 'Git signing' /tmp/dev-signing-doctor.out >/dev/null
