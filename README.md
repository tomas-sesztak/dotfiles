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
| `tmux/` | `~/.tmux.conf` | Fully tracked — no runtime state lives under this directory. |
| `vim/` | `~/.vimrc`, `~/.vim` | Fully tracked — no runtime state lives under this directory. `~/.vimrc` sources `~/.vim/config/tmux.vim`, which isn't tracked (never existed on disk); that `source` line errors on load until the file is added. |
| `zsh/` | `~/.zshrc`, `~/.config/zsh/functions` | `~/.config/zsh/completions` is excluded — it's generated at runtime and isn't tracked. |

## Hotkeys

Neovim's leader key is `<Space>`. tmux's prefix is `C-a` (remapped from the default
`C-b`). Claude Code has no custom keybindings configured in this repo, so it isn't
listed below. ❌ marks an action a tool doesn't support/configure.

### Pane & window movement

Same physical keys move focus in both tools — nvim's bindings fall back to a tmux pane
select when the split boundary is reached, so movement feels seamless across the two.

| Action | nvim | tmux |
|---|---|---|
| Move focus left | `<C-h>` | `<C-h>` |
| Move focus down | `<C-j>` | `<C-j>` |
| Move focus up | `<C-k>` | `<C-k>` |
| Move focus right | `<C-l>` | `<C-l>` |

### Splits & panes

| Action | nvim | tmux |
|---|---|---|
| Split vertically | `<leader>sv` | `<prefix> s` then `h` |
| Split horizontally | `<leader>sh` | `<prefix> s` then `v` |
| Make splits equal size | `<leader>se` | ❌ |
| Close current split/pane | `<leader>sx` | ❌ |
| Reload config | ❌ | `<prefix> r` |

### Tabs & windows

| Action | nvim | tmux |
|---|---|---|
| Open new tab/window | `<leader>to` | ❌ |
| Close current tab | `<leader>tx` | ❌ |
| Go to next tab | `<leader>tn` | ❌ |
| Go to previous tab | `<leader>tp` | ❌ |
| Open current buffer in new tab | `<leader>tf` | ❌ |
| Switch to tab/window #1-9 | `<leader>t1` … `<leader>t9` | ❌ |
| Fuzzy window switcher | ❌ | `<prefix> w` |

### Fuzzy find

| Action | nvim | tmux |
|---|---|---|
| File name search | `<leader>ff` | ❌ |
| File content search | `<leader>fs` | ❌ |
| Buffer switcher | `<leader>fb` | ❌ |

### Editing

| Action | nvim | tmux |
|---|---|---|
| Exit insert mode | `jk` | ❌ |
| Exit visual mode | `jk` | ❌ |
| Clear search highlights | `<leader>,` | ❌ |
| Increment number | `<leader>+` | ❌ |
| Decrement number | `<leader>-` | ❌ |

### LSP

| Action | nvim | tmux |
|---|---|---|
| Open diagnostic float | `<leader>ds` | ❌ |
| Trigger completion (insert mode) | `<leader>cc` | ❌ |
| Format buffer | `<leader>cf` | ❌ |
| Navigate completion popup (insert mode) | `<C-j>` / `<C-k>` | ❌ |
