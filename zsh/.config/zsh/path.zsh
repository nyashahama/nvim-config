typeset -U path PATH

path=(
  "$HOME/.local/bin"
  "$HOME/bin"
  "$HOME/.cargo/bin"
  "$HOME/go/bin"
  "$HOME/.pub-cache/bin"
  "/usr/local/bin"
  $path
)

export GOPATH="${GOPATH:-$HOME/go}"
export GO111MODULE="${GO111MODULE:-on}"
export PATH
