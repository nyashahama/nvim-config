typeset -U path PATH

path=(
  "$HOME/.local/bin"
  "$HOME/bin"
  "$HOME/.cargo/bin"
  "$HOME/go/bin"
  "$HOME/.pub-cache/bin"
  "$BUN_INSTALL/bin"
  "$HOME/.opencode/bin"
  "/usr/local/bin"
  $path
)

export PATH
