# dotfiles

Personal dotfiles, managed with [GNU Stow](https://www.gnu.org/software/stow/) and
deployed to `$HOME`. Each top-level directory in this repo is a Stow package that
mirrors the layout it targets under `$HOME` (e.g. `nvim/.config/nvim/` deploys to
`~/.config/nvim`).

## Getting started

Prerequisite: [GNU Stow](https://www.gnu.org/software/stow/) must be installed.

```sh
./setup.sh deploy      # stow all packages into $HOME (safe to re-run)
./setup.sh undeploy    # remove all symlinks from $HOME
```

Packages are auto-discovered — every top-level directory in the repo (except `.git`)
is treated as a Stow package, so no changes to `setup.sh` are needed when adding a
new one.

## Packages

| Package | Deploys to | Notes |
|---|---|---|
| `claude/` | `~/.claude` | Only `CLAUDE.md` and `settings.json` are tracked; the rest of `~/.claude` is runtime/secret state, excluded via `.gitignore` allowlisting. |
| `nvim/` | `~/.config/nvim` | Fully tracked — no runtime state lives under this directory. |

## Hotkeys

Neovim's leader key is `<Space>`. Claude Code has no custom keybindings configured
in this repo, so it isn't listed below.

| Action | Hotkey | Tool |
|---|---|---|
| Exit insert mode | `jk` | nvim |
| Exit visual mode | `jk` | nvim |
| Clear search highlights | `<leader>,` | nvim |
| Increment number | `<leader>+` | nvim |
| Decrement number | `<leader>-` | nvim |
| Split window vertically | `<leader>sv` | nvim |
| Split window horizontally | `<leader>sh` | nvim |
| Make splits equal size | `<leader>se` | nvim |
| Close current split | `<leader>sx` | nvim |
| Open new tab | `<leader>to` | nvim |
| Close current tab | `<leader>tx` | nvim |
| Go to next tab | `<leader>tn` | nvim |
| Go to previous tab | `<leader>tp` | nvim |
| Open current buffer in new tab | `<leader>tf` | nvim |
| Switch to tab #1-9 | `<leader>t1` … `<leader>t9` | nvim |
| Move to pane/window left | `<C-h>` | nvim (falls back to tmux pane) |
| Move to pane/window down | `<C-j>` | nvim (falls back to tmux pane) |
| Move to pane/window up | `<C-k>` | nvim (falls back to tmux pane) |
| Move to pane/window right | `<C-l>` | nvim (falls back to tmux pane) |
| Fuzzy file name search | `<leader>ff` | nvim |
| Fuzzy file content search | `<leader>fs` | nvim |
| Fuzzy buffer switcher | `<leader>fb` | nvim |
| Open diagnostic float | `<leader>ds` | nvim (LSP) |
| Trigger completion | `<leader>cc` | nvim (LSP, insert mode) |
| Format buffer | `<leader>cf` | nvim (LSP) |
| Navigate completion popup | `<C-j>` / `<C-k>` | nvim (LSP, insert mode) |
