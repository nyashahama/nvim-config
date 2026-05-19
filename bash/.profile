# Login-shell environment for bash.

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

[[ -r "$HOME/.config/bash/env.bash" ]] && source "$HOME/.config/bash/env.bash"

if [[ -n "${BASH_VERSION:-}" && -r "$HOME/.bashrc" ]]; then
	source "$HOME/.bashrc"
fi
