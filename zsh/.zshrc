# Machine-wide interactive shell configuration.

export EDITOR="${EDITOR:-nvim}"
export VISUAL="${VISUAL:-nvim}"
export PAGER="${PAGER:-less}"
export LESS="${LESS:--FRX}"

for file in \
  "$HOME/.config/zsh/path.zsh" \
  "$HOME/.config/zsh/plugins.zsh" \
  "$HOME/.config/zsh/aliases.zsh" \
  "$HOME/.config/zsh/functions.zsh"
do
  [[ -r "$file" ]] && source "$file"
done

[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
