if [[ -t 0 && -t 1 ]]; then
  for fzf_bin in "$HOME/.fzf/bin" "$HOME/.local/share/nvim/lazy/fzf/bin"; do
    [[ -x "$fzf_bin/fzf" ]] && path+=("$fzf_bin")
  done

  if command -v fzf >/dev/null 2>&1; then
    export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:---height 40% --layout=reverse --border}"
    if [[ -r "$HOME/.fzf.zsh" ]]; then
      source "$HOME/.fzf.zsh"
    else
      eval "$(fzf --zsh 2>/dev/null || true)"
    fi
  fi
fi

if [[ -o interactive ]]; then
  for autosuggestions in \
    "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" \
    "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh" \
    "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh" \
    "/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
  do
    if [[ -r "$autosuggestions" ]]; then
      source "$autosuggestions"
      break
    fi
  done
  unset autosuggestions
fi

command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"
command -v mise >/dev/null 2>&1 && eval "$(mise activate zsh)"

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
