# Neovim Config

Systems programming configuration for **C++**, **Go**, and **Rust**.
Requires Neovim 0.11+.

---

## Layout

The config is intentionally split by responsibility:

| Path | Responsibility |
|------|----------------|
| `init.lua` | Version gate, leaders, and module loading |
| `lua/core/` | Options, keymaps, autocommands, commands, lazy.nvim bootstrap |
| `lua/lang/` | C/C++, Go, and Rust filetype/LSP behavior |
| `lua/plugins/` | Plugin specs grouped by UI, navigation, editing, LSP, and DAP |
| `tests/smoke.lua` | Headless load check for the module graph and keymaps |

---

## First-time Setup

```bash
# 1. Open Neovim — lazy.nvim will auto-install all plugins
nvim

# 2. Install LSP servers via Mason
:MasonInstall clangd gopls rust-analyzer

# 3. Install Treesitter parsers (auto-runs on plugin install, or manually)
:TSUpdate

# 4. Verify the config loads
nvim --headless -u NONE -l tests/smoke.lua
```

**System dependencies** you need on your PATH:

| Tool | Used for |
|------|----------|
| `clangd` | C/C++ LSP (or install via Mason) |
| `gopls` | Go LSP (or install via Mason) |
| `rust-analyzer` | Rust LSP (or install via Mason) |
| `ripgrep` (`rg`) | Live grep + file finding fallback |
| `fd` / `fdfind` | Fast file finding for `<C-p>` (preferred over rg/find) |
| `bat` / `batcat` | File preview in `<C-p>` |
| `fzf` | Fuzzy finding (built by lazy.nvim) |
| `gofumpt` | Stricter Go formatting (used by gopls) |
| `codelldb` | C++/Rust debugger adapter (auto-installed via Mason) |
| `delve` | Go debugger adapter (auto-installed via Mason) |

---

## Leader Keys

| Key | Role |
|-----|------|
| `Space` | `<leader>` |
| `,` | `<localleader>` |

Press `<leader>` and wait — **which-key** will show a popup of available bindings.

---

## File Navigation

| Key | Action |
|-----|--------|
| `<C-p>` | Fuzzy find files (fzf) |
| `<C-p>` then `Ctrl-E` | Create a new file at typed path |
| `<leader>ff` | Fuzzy find files |
| `<leader>fb` / `<leader>;` | List open buffers |
| `<leader>sg` / `<leader>rg` | Live ripgrep across project |
| `<leader>ss` | Workspace symbol search (LSP) |
| `<leader><leader>` | Toggle between last two buffers |
| `-` | Open parent directory (oil.nvim) |

Inside **oil.nvim**: navigate with `hjkl`, press `Enter` to open, `-` to go up, `_` to open CWD. It edits the filesystem like a buffer — delete a line to delete a file, rename by editing the name.

**vim-rooter** automatically sets the working directory to the project root (looks for `go.mod`, `.git`, `Cargo.toml`, `compile_commands.json`, etc.).

---

## Motion & Editing

| Key | Action |
|-----|--------|
| `s` + 2 chars | Leap forward to match |
| `S` + 2 chars | Leap backward to match |
| `H` | Jump to start of line (`^`) |
| `L` | Jump to end of line (`$`) |
| `<A-j>` / `<A-k>` | Move current line / selection up or down |
| `<` / `>` (visual) | Indent and stay in visual mode |
| `jk` | Exit insert/visual/terminal mode |
| `;` | Enter command mode (replaces `:`) |

---

## Windows & Splits

| Key | Action |
|-----|--------|
| `<leader>sv` | Vertical split |
| `<leader>sh` | Horizontal split |
| `<leader>sx` | Close split |
| `<leader>s=` | Equalize split sizes |
| `<leader>h/j/k/l` | Move between windows |

---

## Completion & Snippets

Completion is powered by **nvim-cmp** + **LuaSnip** with VSCode-style snippets via `friendly-snippets`.

| Key | Action |
|-----|--------|
| `Tab` | Next completion item / expand or jump snippet |
| `S-Tab` | Previous completion item / jump back in snippet |
| `CR` | Confirm selection |
| `C-Space` | Force open completion menu |
| `C-e` | Abort completion |
| `C-b` / `C-f` | Scroll docs up/down |

Ghost text shows the top suggestion inline as you type.

---

## LSP (all languages)

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gi` | Go to implementation |
| `gr` | Show all references |
| `K` | Hover documentation |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |
| `<leader>cf` | Format buffer |
| `[d` / `]d` | Previous / next diagnostic |
| `<leader>xd` | Show diagnostic float |
| `<leader>xl` | Send diagnostics to location list |

Symbols under the cursor are **highlighted** across the buffer automatically on `CursorHold`.

---

## C++ (`<localleader>`, comma by default)

| Key | Action |
|-----|--------|
| `<localleader>h` | Switch between header and source (`ClangdSwitchSourceHeader`) |
| `<localleader>t` | Type hierarchy |
| `<localleader>s` | Symbol info |
| `<localleader>m` | clangd memory usage |

**clangd** is configured with:
- Background indexing
- `clang-tidy` integration
- IWYU header insertion
- Detailed completion with argument placeholders
- Auto-detects C++ standard from `compile_commands.json` or `CMakeLists.txt` (defaults to C++20)

**Tip:** Run `:CreateClangdConfig` in any C++ project to generate a `.clangd` file with the detected standard and strict include diagnostics.

**For best results**, generate `compile_commands.json`:
```bash
# CMake
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -B build

# Bear (for Make-based projects)
bear -- make
```

---

## Go (`<localleader>`, comma by default)

| Key | Action |
|-----|--------|
| `<localleader>i` | Organize imports (via gopls code action) |
| `<localleader>t` | `go test ./...` in terminal |
| `<localleader>b` | `go build ./...` in terminal |
| `<localleader>r` | `go run .` in terminal |

**gopls** is configured with:
- `gofumpt` formatting
- `staticcheck` analysis
- Unused params + shadow variable analysis
- Full inlay hints (types, parameter names, composite literal fields)

Format on save is active for all `.go` files.

---

## Rust (`<localleader>`, comma by default)

| Key | Action |
|-----|--------|
| `<localleader>r` | Show runnables (tests, binaries, examples) |
| `<localleader>d` | Show debuggables |
| `<localleader>e` | Expand macro under cursor |
| `<localleader>c` | Open `Cargo.toml` |
| `<localleader>p` | Go to parent module |

**rust-analyzer** via **rustaceanvim** is configured with:
- `clippy` on save (instead of `cargo check`)
- All cargo features enabled
- Inlay hints: binding modes, closure return types, non-trivial lifetime hints

Format on save runs `rustfmt` via rust-analyzer.

**Tip:** `<localleader>r` is your best friend — it finds all runnable targets in the workspace and lets you pick one. Much faster than typing `cargo run --example foo` manually.

---

## Git (`<leader>g`, `[h`/`]h`)

| Key | Action |
|-----|--------|
| `<leader>gb` | Full blame for current line |
| `<leader>gd` | Diff this file |
| `<leader>gp` | Preview hunk inline |
| `<leader>gr` | Reset hunk to HEAD |
| `[h` / `]h` | Previous / next hunk |

Gutter signs show `|` for added/changed lines, `_` for deleted lines.

---

## Debugger (`<leader>d`)

Powered by **nvim-dap** + **nvim-dap-ui**. Adapters are auto-installed via Mason:
- `codelldb` — C++ and Rust
- `delve` — Go

| Key | Action |
|-----|--------|
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Set conditional breakpoint |
| `<leader>dc` | Continue / start session |
| `<leader>di` | Step into |
| `<leader>do` | Step over |
| `<leader>dO` | Step out |
| `<leader>dr` | Open REPL |
| `<leader>du` | Toggle DAP UI |
| `<leader>dx` | Terminate session |

The UI opens automatically when a debug session starts and closes when it ends. Debug signs use simple gutter markers: `B` for breakpoints, `C` for conditional breakpoints, and `>` for the stopped line.

**Rust tip:** Use `<localleader>d` (rustaceanvim debuggables) instead of `<leader>dc` to start — it lets you pick the exact binary/test to debug with the right args.

---

## Terminal

| Key | Action |
|-----|--------|
| `<C-\>` | Toggle floating terminal |
| `jk` (in terminal) | Return to normal mode |

The terminal floats at 90% width × 80% height with a rounded border.

---

## Quickfix

| Key | Action |
|-----|--------|
| `<leader>xq` | Open quickfix list |
| `<leader>xQ` | Close quickfix list |
| `[q` / `]q` | Previous / next quickfix entry |

---

## Clipboard

| Key | Action |
|-----|--------|
| `<leader>y` | Yank to system clipboard |
| `<leader>p` | Paste from system clipboard |

The config also sets `clipboard=unnamedplus` so all yanks/pastes go through the system clipboard by default.

---

## Searching

| Key | Action |
|-----|--------|
| `<C-h>` | Clear search highlights |
| `n` / `N` | Next/prev result, centered on screen |
| `<leader>sg` | Search project with ripgrep |

---

## Utility Commands

| Command | Action |
|---------|--------|
| `:CreateClangdConfig` | Write a `.clangd` file for the current C++ project |
| `:LspInfo` | Show which LSP clients are attached to the current buffer |
| `:Mason` | Open Mason UI to install/manage LSP servers and tools |
| `:Lazy` | Open lazy.nvim UI to update or inspect plugins |
| `:TSUpdate` | Update Treesitter parsers |

---

## Language-specific Indentation

| Language | Style |
|----------|-------|
| C/C++ | 2 spaces |
| Go | Tabs (width 8, per Go standard) |
| Rust | 4 spaces |
| Make/CMake | Tabs (width 8) |
| Everything else | 2 spaces |

---

## Plugins at a Glance

| Plugin | Purpose |
|--------|---------|
| gruvbox.nvim | Dark colorscheme (hard contrast) |
| lualine.nvim | Status line |
| which-key.nvim | Keymap popup guide |
| leap.nvim | Fast 2-char jump motions |
| fzf + fzf.vim | Fuzzy file/buffer/grep search |
| oil.nvim | File explorer as a buffer |
| gitsigns.nvim | Git hunk signs and actions |
| Comment.nvim | `gc`/`gb` comment toggling |
| toggleterm.nvim | Floating terminal |
| nvim-treesitter | Syntax, indentation, selection |
| indent-blankline | Indent guides |
| nvim-autopairs | Auto-close brackets/quotes |
| nvim-cmp | Completion engine |
| LuaSnip | Snippet engine |
| mason.nvim | LSP/tool installer |
| nvim-lspconfig | LSP client configuration |
| fidget.nvim | LSP progress spinner |
| nvim-dap | Debug adapter protocol client |
| nvim-dap-ui | Debug UI (auto-opens with session) |
| mason-nvim-dap | Auto-install debug adapters via Mason |
| rustaceanvim | Rust-specific LSP features |
