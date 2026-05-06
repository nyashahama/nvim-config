alias v='nvim'
alias vim='nvim'
alias c='clear'
alias h='history'

alias gs='git status --short --branch'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate --all'
alias gp='git push'
alias gpl='git pull --ff-only'
alias gc='git commit'
alias gcm='git commit -m'
alias ga='git add'
alias gb='git branch'
alias gco='git checkout'

alias cr='cargo run'
alias cb='cargo build'
alias ct='cargo test'
alias cc='cargo check'
alias ccl='cargo clippy'
alias cf='cargo fmt'

alias gor='go run'
alias gob='go build'
alias got='go test'
alias gom='go mod'
alias gof='go fmt'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

if command -v eza >/dev/null 2>&1; then
  alias ls='eza'
  alias ll='eza -alh'
  alias la='eza -la'
  alias tree='eza --tree'
else
  alias ll='ls -alh'
  alias la='ls -A'
fi

if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
  alias fd='fdfind'
fi

if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
  alias bat='batcat'
fi

alias serve='python3 -m http.server'
alias ports='ss -ltnp'
alias d='docker'
alias dps='docker ps'
