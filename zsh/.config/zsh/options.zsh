HISTFILE="${HISTFILE:-$HOME/.zsh_history}"
HISTSIZE=50000
SAVEHIST=50000

setopt append_history
setopt auto_cd
setopt auto_pushd
setopt extended_glob
setopt hist_find_no_dups
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_reduce_blanks
setopt hist_save_no_dups
setopt inc_append_history
setopt interactive_comments
setopt no_beep
setopt prompt_subst
setopt pushd_ignore_dups
setopt share_history

autoload -Uz compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"

zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-$ZSH_VERSION"
mkdir -p "${zcompdump:h}" "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"
compinit -d "$zcompdump"

# Keep Ctrl-R available for reverse history search when EDITOR=nvim selects vi keymaps.
bindkey -M main '^R' history-incremental-search-backward
bindkey -M viins '^R' history-incremental-search-backward
