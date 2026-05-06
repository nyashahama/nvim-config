mkproject() {
  if [[ $# -ne 1 ]]; then
    echo "Usage: mkproject <name>" >&2
    return 2
  fi

  mkdir -p "$1"
  cd "$1" || return
  git init
  printf '# %s\n' "$1" > README.md
  printf '%s\n' '.env' '*.log' 'target/' 'node_modules/' > .gitignore
}

killport() {
  if [[ $# -ne 1 ]]; then
    echo "Usage: killport <port>" >&2
    return 2
  fi

  lsof -ti:"$1" | xargs --no-run-if-empty kill -TERM
}

extract() {
  if [[ $# -ne 1 || ! -f "$1" ]]; then
    echo "Usage: extract <archive>" >&2
    return 2
  fi

  case "$1" in
    *.tar.bz2|*.tbz2) tar xjf "$1" ;;
    *.tar.gz|*.tgz) tar xzf "$1" ;;
    *.tar.xz) tar xJf "$1" ;;
    *.tar) tar xf "$1" ;;
    *.bz2) bunzip2 "$1" ;;
    *.gz) gunzip "$1" ;;
    *.zip) unzip "$1" ;;
    *.7z) 7z x "$1" ;;
    *) echo "Unsupported archive: $1" >&2; return 1 ;;
  esac
}

backup() {
  if [[ $# -ne 1 || ! -e "$1" ]]; then
    echo "Usage: backup <path>" >&2
    return 2
  fi

  cp -a "$1" "$1.bak"
}
