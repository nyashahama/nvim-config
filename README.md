# Dotfiles

Personal dotfiles for an Ubuntu-based development workstation. The repository
lives at `~/.dotfiles`, uses a Stow-compatible package layout, and keeps each
tool's config in the same shape it will have under `$HOME`.

Neovim is the primary editor. VS Code remains managed as a fallback for extension
or pairing workflows, but the day-to-day workflow is optimized around Neovim,
Ghostty, zsh, tmux, git, mise, and small `dev-*` commands.

---

## Layout

| Path | Purpose |
|------|---------|
| `nvim/` | Neovim package; links back to the current single-source config |
| `zsh/` | primary interactive shell: environment, path, options, tools, prompt, aliases |
| `bash/` | clean fallback shell with matching core environment |
| `git/` | global Git config and ignore file |
| `ghostty/` | default terminal environment integration |
| `mise/` | cross-language runtime and tool manager config |
| `starship/` | cross-shell prompt config |
| `ssh/` | SSH client defaults; never private keys |
| `templates/` | reusable project bootstrap templates |
| `vscode/` | VS Code user settings, keybindings, snippets, and extension manifest |
| `alacritty/` | legacy fallback terminal config |
| `tmux/` | tmux session/workspace config |
| `scripts/` | personal commands installed into `~/.local/bin` |
| `system/` | Ubuntu package list for workstation bootstrap |
| `tests/` | smoke tests for dotfiles and Neovim |
| `docs/nvim.md` | detailed Neovim usage notes |

---

## First Run

Check what the bootstrap would install:

```bash
./bootstrap.sh --check
```

Install base workstation tools:

```bash
./bootstrap.sh --install
```

Run repo checks:

```bash
make test
./scripts/.local/bin/dotfiles-doctor
```

Preview symlinks without changing the machine:

```bash
./install.sh --dry-run
```

Apply non-Neovim packages:

```bash
./install.sh --apply zsh bash git ghostty starship tmux scripts vscode mise ssh templates
```

---

## Shell And Terminal

Ghostty is the default terminal. zsh is the primary interactive shell, while
bash remains a clean fallback for compatibility.

The shell setup is intentionally split into small files:

- `zsh/.zprofile`: login-shell XDG setup
- `zsh/.zshrc`: interactive zsh entrypoint
- `zsh/.config/zsh/*.zsh`: environment, path, options, tools, aliases, functions, prompt
- `bash/.bashrc`: interactive bash fallback
- `bash/.profile`: bash login-shell handoff
- `bash/.config/bash/*.bash`: bash environment, aliases, and tool hooks

Machine-local overrides belong in `~/.zshrc.local`, `~/.bashrc.local`, or
`~/.config/environment.d/*.conf`.

Aliases worth remembering:

```bash
doctor  # detect useful commands for the current repo
devinit # copy base dev templates into the current repo
devupdate # preview workstation update commands
gpr     # show local branch, upstream, PR metadata, and PR checks
gchecks # show current PR checks, or recent workflow runs when no PR exists
greviews # show formal reviews, top-level comments, and inline review comments
gopenpr # open the current PR, or create one in the browser
devbackup # create a secrets-safe workstation config backup
devfonts # check terminal font/theme setup
devsigning # check Git SSH signing readiness
lg      # lazygit
j       # just
```

---

## Editor

Neovim is the primary editor:

```bash
nvim
```

Useful Neovim workstation commands:

```text
:DevProject      pick a project
:DevDoctor       run dev-repo-doctor
:DevPr           show PR status
:DevChecks       show PR checks or recent workflow runs
:DevReviews      show formal reviews, top-level comments, and inline review comments
:DevOpenPr       open PR create/view flow
:DevUpdate       preview workstation update commands
:DevBackup       create a workstation config backup
:DevSigning      check Git SSH signing readiness
:DevFonts        check terminal font/theme setup
:DevPerf         run performance audit
:DbPsql          open psql
:DbRedis         open redis-cli
:DbSqlite        open sqlite3
:NvimTrimLspLog  rotate oversized LSP log
```

Useful Neovim reading/editing keys:

```text
<leader>mp      toggle rendered Markdown preview for the current buffer
```

VS Code user config is still managed by the `vscode` package:

```text
~/.config/Code/User/settings.json
~/.config/Code/User/keybindings.json
~/.config/Code/User/snippets/dev.code-snippets
```

The extension manifest lives at:

```text
vscode/.config/Code/User/extensions.txt
```

Install or update the managed extension set:

```bash
while read -r extension; do
  code --install-extension "$extension"
done < vscode/.config/Code/User/extensions.txt
```

VS Code history, workspace storage, and extension global state are intentionally
left outside Stow.

---

## Toolchains

`mise` is the primary runtime manager for new shells and projects. The global
config tracks current Go, Node LTS, and uv:

```text
~/.config/mise/config.toml
```

Install the managed runtime set:

```bash
mise install
```

Rust stays on `rustup`, with `rust-src`, `rustfmt`, `clippy`, and
`rust-analyzer` components. Go tools still install into `~/go/bin`, which is on
PATH. Python projects should prefer `uv` for virtualenv and dependency work.

---

## Project Bootstrap

New or under-tooled repositories can get a small baseline:

```bash
dev-init /path/to/repo
```

This copies `.editorconfig`, `.envrc`, `.pre-commit-config.yaml`, `mise.toml`,
and `justfile` from:

```text
~/.local/share/dev-templates/base
```

`dev-init` refuses to overwrite existing files. Use `dev-init --force` only when
you intentionally want to replace local versions.

---

## Maintenance And Security

Preview the managed workstation update flow:

```bash
dev-update --check
```

Apply it:

```bash
dev-update --apply
```

The update command covers Ubuntu packages, mise runtimes, Rust components, Go
developer tools, `uv` tools, VS Code extensions, the devcontainer CLI, and mise
reshims.

Git uses Neovim as the editor, a commit template, verbose commits, GitHub CLI
credentials, and SSH-backed commit signing:

```bash
dev-signing-doctor --check
dev-signing-doctor --apply
```

The signing setup stores only public metadata in `~/.config/git/allowed_signers.local`.
Private keys stay in `~/.ssh` and are never tracked.

To make GitHub show SSH-signed commits as verified, refresh the signing-key API
scope once and then add the public key:

```bash
gh auth refresh -h github.com -s admin:ssh_signing_key
dev-signing-doctor --github-add
```

GitHub CLI helpers are reproducible:

```bash
dev-gh aliases --check
dev-gh aliases --apply
```

The aliases added to `gh` are `pr-status`, `pr-checks`, `pr-reviews`,
`pr-open`, and `runs`.

Create a secrets-safe backup before major machine changes:

```bash
dev-backup --check
dev-backup --run
```

`dev-backup` copies shell/editor/Git/terminal config and excludes SSH private
keys, known hosts, `.gitconfig.local`, tokens, password stores, and editor state.

Install or check the terminal font/theme layer:

```bash
dev-fonts --install
dev-fonts --check
```

Ghostty is managed with `Gruvbox Dark Hard` and `JetBrainsMono Nerd Font`, which
matches the Neovim theme and keeps terminal glyphs/icons consistent.

Run a quick local performance audit:

```bash
dev-perf --run
```

SSH config is managed, but keys are not. Private keys, known hosts, passwords,
tokens, password stores, and machine-only overrides stay local.

---

## Neovim

The local Neovim config is available through this symlink:

```text
~/.config/nvim -> ~/.dotfiles/nvim/.config/nvim
```

The default install excludes `nvim` because this link already exists. If you want
GNU Stow to recreate it later, confirm the link target, remove only the symlink,
then stow the package:

```bash
readlink ~/.config/nvim
unlink ~/.config/nvim
./install.sh --dry-run nvim
./install.sh --apply nvim
```

---

## Packages

The package names match the top-level directories:

```bash
./install.sh --dry-run nvim zsh bash git ghostty starship alacritty tmux scripts vscode mise ssh templates
./install.sh --apply zsh bash git ghostty starship tmux scripts vscode mise ssh templates
```

`system/` is documentation for packages, not a Stow package.

---

## Rollback

Before replacing live files, create a timestamped backup directory:

```bash
backup="$HOME/.dotfiles-backups/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup"
for path in "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.profile" "$HOME/.tmux.conf" "$HOME/.config/Code/User/settings.json" "$HOME/.config/mise/config.toml" "$HOME/.ssh/config"; do
  [[ -e "$path" || -L "$path" ]] && cp -a "$path" "$backup/"
done
```

To roll back, move the saved files back into `$HOME` or remove the Stow symlinks
for the affected package and restore the matching backup.

---

## Private Config

Do not commit secrets or machine-only overrides. Keep private files in:

```text
~/.zshrc.local
~/.bashrc.local
~/.gitconfig.local
.env
.env.*
```

The repo intentionally ignores `.claude/`, `docs/superpowers/`, local env files,
backups, and temp files.

---

## Useful Commands

```bash
make test       # layout + Neovim smoke checks
make doctor     # report installed/missing workstation tools
make check      # bootstrap check + doctor + tests
make bootstrap  # install Ubuntu packages
make dry-run    # preview Stow operations
make install    # apply default Stow packages
```
