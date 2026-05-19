#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
user_dir="$root/vscode/.config/Code/User"
settings="$user_dir/settings.json"
keybindings="$user_dir/keybindings.json"
snippets="$user_dir/snippets/dev.code-snippets"
extensions="$user_dir/extensions.txt"

for file in "$settings" "$keybindings" "$snippets" "$extensions"; do
	if [[ ! -f "$file" ]]; then
		printf 'missing VS Code config file: %s\n' "$file" >&2
		exit 1
	fi
done

jq empty "$settings"
jq empty "$keybindings"
jq empty "$snippets"

jq -e '."terminal.integrated.defaultProfile.linux" == "zsh"' "$settings" >/dev/null
jq -e '."editor.formatOnSave" == true' "$settings" >/dev/null
jq -e '."go.toolsManagement.autoUpdate" == true' "$settings" >/dev/null
jq -e '."rust-analyzer.check.command" == "clippy"' "$settings" >/dev/null
jq -e '."python.defaultInterpreterPath" == "python3"' "$settings" >/dev/null

if grep -nE '^[[:space:]]*$|^[[:space:]]*#' "$extensions"; then
	printf 'extensions manifest must not contain blank lines or comments\n' >&2
	exit 1
fi

if grep -nEv '^[[:alnum:]_-]+\.[[:alnum:]_.-]+$' "$extensions"; then
	printf 'extensions manifest contains invalid extension identifiers\n' >&2
	exit 1
fi

duplicates="$(sort "$extensions" | uniq -d)"
if [[ -n "$duplicates" ]]; then
	printf 'extensions manifest contains duplicates:\n%s\n' "$duplicates" >&2
	exit 1
fi

required_extensions=(
	"golang.go"
	"rust-lang.rust-analyzer"
	"ms-python.python"
	"charliermarsh.ruff"
	"esbenp.prettier-vscode"
	"redhat.vscode-yaml"
	"github.vscode-pull-request-github"
)

for extension in "${required_extensions[@]}"; do
	if ! grep -Fx "$extension" "$extensions" >/dev/null; then
		printf 'missing required VS Code extension: %s\n' "$extension" >&2
		exit 1
	fi
done
