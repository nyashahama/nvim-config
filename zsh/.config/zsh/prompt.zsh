if [[ -t 1 && "${TERM:-}" != "dumb" ]] && command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
else
  autoload -Uz vcs_info
  precmd() { vcs_info }
  zstyle ':vcs_info:git:*' formats ' %F{blue}(%b)%f'
  PROMPT='%F{green}%n@%m%f:%F{blue}%~%f${vcs_info_msg_0_} %# '
fi
