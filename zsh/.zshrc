# Primary interactive zsh configuration.

[[ -o interactive ]] || return

for file in \
  "$HOME/.config/zsh/env.zsh" \
  "$HOME/.config/zsh/path.zsh" \
  "$HOME/.config/zsh/options.zsh" \
  "$HOME/.config/zsh/tools.zsh" \
  "$HOME/.config/zsh/aliases.zsh" \
  "$HOME/.config/zsh/functions.zsh" \
  "$HOME/.config/zsh/prompt.zsh"
do
  [[ -r "$file" ]] && source "$file"
done

[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
