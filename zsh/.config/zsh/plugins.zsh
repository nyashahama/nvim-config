HISTFILE="${HISTFILE:-$HOME/.zsh_history}"
HISTSIZE=50000
SAVEHIST=50000

setopt append_history
setopt auto_cd
setopt auto_pushd
setopt hist_find_no_dups
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_save_no_dups
setopt inc_append_history
setopt pushd_ignore_dups
setopt share_history

if [[ -d "$HOME/.oh-my-zsh" ]]; then
  export ZSH="$HOME/.oh-my-zsh"
  ZSH_THEME="${ZSH_THEME:-powerlevel10k/powerlevel10k}"
  plugins=(git docker docker-compose golang rust colored-man-pages command-not-found)

  custom="${ZSH_CUSTOM:-$ZSH/custom}"
  [[ -d "$custom/plugins/zsh-autosuggestions" ]] && plugins+=(zsh-autosuggestions)
  [[ -d "$custom/plugins/zsh-syntax-highlighting" ]] && plugins+=(zsh-syntax-highlighting)
  [[ -d "$custom/plugins/history-substring-search" ]] && plugins+=(history-substring-search)

  # shellcheck source=/dev/null
  source "$ZSH/oh-my-zsh.sh"
else
  autoload -Uz compinit
  compinit
  zstyle ':completion:*' menu select
  zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
fi

if command -v fzf >/dev/null 2>&1; then
  export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:---height 40% --layout=reverse --border}"
fi

command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"
command -v mise >/dev/null 2>&1 && eval "$(mise activate zsh)"

[[ -r "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"
