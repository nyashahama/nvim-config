#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

required_paths=(
	"$root/bootstrap.sh"
	"$root/install.sh"
	"$root/Makefile"
	"$root/system/packages.apt"
	"$root/nvim/.config/nvim/init.lua"
	"$root/bash/.bashrc"
	"$root/bash/.profile"
	"$root/bash/.config/bash/env.bash"
	"$root/bash/.config/bash/aliases.bash"
	"$root/bash/.config/bash/tools.bash"
	"$root/zsh/.zshrc"
	"$root/zsh/.config/zsh/env.zsh"
	"$root/zsh/.config/zsh/aliases.zsh"
	"$root/zsh/.config/zsh/functions.zsh"
	"$root/zsh/.config/zsh/options.zsh"
	"$root/zsh/.config/zsh/path.zsh"
	"$root/zsh/.config/zsh/prompt.zsh"
	"$root/zsh/.config/zsh/plugins.zsh"
	"$root/zsh/.config/zsh/tools.zsh"
	"$root/git/.gitconfig"
	"$root/git/.config/git/ignore"
	"$root/git/.config/git/commit-template"
	"$root/ghostty/.config/ghostty/config"
	"$root/ghostty/.config/environment.d/10-terminal.conf"
	"$root/mise/.config/mise/config.toml"
	"$root/mise/.config/mise/tasks/workstation.toml"
	"$root/starship/.config/starship.toml"
	"$root/ssh/.ssh/config"
	"$root/templates/.local/share/dev-templates/base/.editorconfig"
	"$root/templates/.local/share/dev-templates/base/.envrc"
	"$root/templates/.local/share/dev-templates/base/.pre-commit-config.yaml"
	"$root/templates/.local/share/dev-templates/base/mise.toml"
	"$root/templates/.local/share/dev-templates/base/justfile"
	"$root/vscode/.config/Code/User/settings.json"
	"$root/vscode/.config/Code/User/keybindings.json"
	"$root/vscode/.config/Code/User/snippets/dev.code-snippets"
	"$root/vscode/.config/Code/User/extensions.txt"
	"$root/alacritty/.config/alacritty/alacritty.toml"
	"$root/tmux/.tmux.conf"
	"$root/scripts/.local/bin/dev-init"
	"$root/scripts/.local/bin/dev-backup"
	"$root/scripts/.local/bin/dev-fonts"
	"$root/scripts/.local/bin/dev-gh"
	"$root/scripts/.local/bin/dev-perf"
	"$root/scripts/.local/bin/dev-pr"
	"$root/scripts/.local/bin/dev-repo-doctor"
	"$root/scripts/.local/bin/dev-signing-doctor"
	"$root/scripts/.local/bin/dev-update"
	"$root/scripts/.local/bin/dotfiles-doctor"
	"$root/tests/dev_init.sh"
	"$root/tests/neovim_primary.sh"
	"$root/tests/shell_startup.sh"
	"$root/tests/workstation_workflow.sh"
	"$root/tests/vscode_config.sh"
)

for path in "${required_paths[@]}"; do
	if [[ ! -e "$path" ]]; then
		printf 'missing required path: %s\n' "$path" >&2
		exit 1
	fi
done

email_typo_pattern='user\.emai([^[:alpha:]]|$)'
if command -v rg >/dev/null 2>&1; then
	if rg -n "$email_typo_pattern" "$root/git" "$root/zsh" "$root/system" "$root/scripts" "$root/alacritty" "$root/tmux" "$root/README.md"; then
		exit 1
	fi
else
	if grep -R -E -n "$email_typo_pattern" "$root/git" "$root/zsh" "$root/system" "$root/scripts" "$root/alacritty" "$root/tmux" "$root/README.md"; then
		exit 1
	fi
fi

bash -n "$root/bootstrap.sh"
bash -n "$root/install.sh"
bash -n "$root/scripts/.local/bin/dev-init"
bash -n "$root/scripts/.local/bin/dev-backup"
bash -n "$root/scripts/.local/bin/dev-fonts"
bash -n "$root/scripts/.local/bin/dev-gh"
bash -n "$root/scripts/.local/bin/dev-perf"
bash -n "$root/scripts/.local/bin/dev-pr"
bash -n "$root/scripts/.local/bin/dev-repo-doctor"
bash -n "$root/scripts/.local/bin/dev-signing-doctor"
bash -n "$root/scripts/.local/bin/dev-update"
bash -n "$root/scripts/.local/bin/dotfiles-doctor"

for file in \
	"$root/bash/.bashrc" \
	"$root/bash/.profile" \
	"$root/bash/.config/bash/env.bash" \
	"$root/bash/.config/bash/aliases.bash" \
	"$root/bash/.config/bash/tools.bash"; do
	bash -n "$file"
done

for file in \
	"$root/zsh/.zprofile" \
	"$root/zsh/.zshrc" \
	"$root/zsh/.config/zsh/env.zsh" \
	"$root/zsh/.config/zsh/path.zsh" \
	"$root/zsh/.config/zsh/options.zsh" \
	"$root/zsh/.config/zsh/prompt.zsh" \
	"$root/zsh/.config/zsh/tools.zsh" \
	"$root/zsh/.config/zsh/aliases.zsh" \
	"$root/zsh/.config/zsh/functions.zsh"; do
	zsh -n "$file"
done
