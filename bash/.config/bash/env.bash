# Shared Bash environment for interactive and login shells.

export EDITOR="${EDITOR:-nvim}"
export VISUAL="${VISUAL:-nvim}"
export PAGER="${PAGER:-less}"
export LESS="${LESS:--FRX}"
export TERMINAL="${TERMINAL:-ghostty}"

export GOPATH="${GOPATH:-$HOME/go}"
export GO111MODULE="${GO111MODULE:-on}"
export BUN_INSTALL="${BUN_INSTALL:-$HOME/.bun}"
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

path_prepend() {
	case ":$PATH:" in
	*":$1:"*) ;;
	*) PATH="$1:$PATH" ;;
	esac
}

path_prepend "$HOME/.local/bin"
path_prepend "$HOME/bin"
path_prepend "$HOME/.cargo/bin"
path_prepend "$HOME/go/bin"
path_prepend "$HOME/.pub-cache/bin"
path_prepend "$BUN_INSTALL/bin"
path_prepend "$HOME/.opencode/bin"

export PATH
