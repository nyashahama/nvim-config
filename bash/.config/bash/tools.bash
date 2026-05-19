if [[ -r "$HOME/.fzf.bash" ]]; then
	source "$HOME/.fzf.bash"
elif command -v fzf >/dev/null 2>&1; then
	eval "$(fzf --bash 2>/dev/null || true)"
fi

command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init bash)"
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook bash)"
command -v mise >/dev/null 2>&1 && eval "$(mise activate bash)"
if [[ -t 1 && "${TERM:-}" != "dumb" ]] && command -v starship >/dev/null 2>&1; then
	eval "$(starship init bash)"
fi

load_nvm() {
	[[ -r "$NVM_DIR/nvm.sh" ]] || return 127
	unset -f nvm node npm npx yarn pnpm ng corepack
	source "$NVM_DIR/nvm.sh"
}

nvm() { load_nvm && nvm "$@"; }

if ! command -v node >/dev/null 2>&1; then
	node() { load_nvm && command node "$@"; }
	npm() { load_nvm && command npm "$@"; }
	npx() { load_nvm && command npx "$@"; }
	yarn() { load_nvm && command yarn "$@"; }
	pnpm() { load_nvm && command pnpm "$@"; }
	ng() { load_nvm && command ng "$@"; }
	corepack() { load_nvm && command corepack "$@"; }
fi
