# Bash fallback interactive shell configuration.

case $- in
*i*) ;;
*) return ;;
esac

set -o pipefail
shopt -s checkwinsize histappend

HISTCONTROL=ignoreboth:erasedups
HISTSIZE=50000
HISTFILESIZE=50000

for file in \
	"$HOME/.config/bash/env.bash" \
	"$HOME/.config/bash/aliases.bash" \
	"$HOME/.config/bash/tools.bash"; do
	[[ -r "$file" ]] && source "$file"
done

[[ -r "$HOME/.bashrc.local" ]] && source "$HOME/.bashrc.local"
