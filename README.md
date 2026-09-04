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
| `copilot/` | `~/.copilot` | Only file is `copilot-instructions.md`, a symlink to `claude/.claude/CLAUDE.md` so both tools share one global instructions source. |
| `herdr/` | `~/.config/herdr` | `config.toml` and `scripts/smart-pane-nav.sh` are tracked; the rest (logs, sockets, session state) is runtime state, excluded via `.gitignore` allowlisting. |
| `nvim/` | `~/.config/nvim` | Fully tracked — no runtime state lives under this directory. |
| `tmux/` | `~/.tmux.conf` | Fully tracked — no runtime state lives under this directory. |
| `vim/` | `~/.vimrc`, `~/.vim` | Fully tracked — no runtime state lives under this directory. `~/.vimrc` sources `~/.vim/config/tmux.vim`, which isn't tracked (never existed on disk); that `source` line errors on load until the file is added. |
| `zsh/` | `~/.zshrc`, `~/.config/zsh/functions` | `~/.config/zsh/completions` is excluded — it's generated at runtime and isn't tracked. `.zshrc` prepends the [XDG](https://specifications.freedesktop.org/basedir-spec/latest/) standard `~/.local/bin` to `PATH` (if present) for user-supplied binaries. |

## Hotkeys

Neovim's and vim's leader key is `<Space>`. tmux's and herdr's prefix is both `C-a`
(tmux's remapped from the default `C-b`; herdr's set to match). Claude Code has no
custom keybindings configured in this repo, so it isn't listed below. ❌ marks an
action a tool doesn't support/configure.

### Pane & window movement

Same physical keys move focus in all four tools — nvim's, vim's, and herdr's bindings
fall back to a multiplexer (tmux or herdr) pane select when the split boundary is
reached, so movement feels seamless across editor and multiplexer.

| Action | nvim | vim | tmux | herdr |
|---|---|---|---|---|
| Move focus left | `<C-h>` | `<C-h>` | `<C-h>` | `<C-h>` |
| Move focus down | `<C-j>` | `<C-j>` | `<C-j>` | `<C-j>` |
| Move focus up | `<C-k>` | `<C-k>` | `<C-k>` | `<C-k>` |
| Move focus right | `<C-l>` | `<C-l>` | `<C-l>` | `<C-l>` |

### Splits & panes

| Action | nvim | vim | tmux | herdr |
|---|---|---|---|---|
| Split vertically | `<leader>sv` | `<leader>sv` | `<prefix> s` then `h` | `<prefix> v` |
| Split horizontally | `<leader>sh` | `<leader>sh` | `<prefix> s` then `v` | `<prefix> h` |
| Make splits equal size | `<leader>se` | `<leader>se` | ❌ | ❌ |
| Close current split/pane | `<leader>sx` | `<leader>sx` | ❌ | ❌ |
| Toggle fullscreen (zoom) pane | ❌ | ❌ | `<prefix> z` | ❌ |
| Reload config | ❌ | `<leader>r` | `<prefix> r` | `<prefix> r` |

### Tabs, windows & workspaces

| Action | nvim | vim | tmux | herdr |
|---|---|---|---|---|
| Open new tab/window | `<leader>to` | `<leader>to` | ❌ | ❌ |
| Close current tab | `<leader>tx` | `<leader>tx` | ❌ | ❌ |
| Go to next tab/workspace | `<leader>tn` | `<leader>tn` | ❌ | `<prefix> }` |
| Go to previous tab/workspace | `<leader>tp` | `<leader>tp` | ❌ | `<prefix> {` |
| Open current buffer in new tab | `<leader>tf` | `<leader>tf` | ❌ | ❌ |
| Switch to tab/window #1-9 | `<leader>t1` … `<leader>t9` | `<leader>t1` … `<leader>t9` | ❌ | ❌ |
| Fuzzy window switcher | ❌ | ❌ | `<prefix> w` | ❌ |

### Fuzzy find

| Action | nvim | vim | tmux | herdr |
|---|---|---|---|---|
| File name search | `<leader>ff` | `<leader>ff` | ❌ | ❌ |
| File content search | `<leader>fs` | `<leader>fs` | ❌ | ❌ |
| Buffer switcher | `<leader>fb` | `<leader>fb` | ❌ | ❌ |

### Editing

| Action | nvim | vim | tmux | herdr |
|---|---|---|---|---|
| Exit insert mode | `jk` | `jk` | ❌ | ❌ |
| Exit visual mode | `jk` | `jk` | ❌ | ❌ |
| Clear search highlights | `<leader>,` | `<leader>,` | ❌ | ❌ |
| Increment number | `<leader>+` | `<leader>+` | ❌ | ❌ |
| Decrement number | `<leader>-` | `<leader>-` | ❌ | ❌ |

### LSP

| Action | nvim | vim | tmux | herdr |
|---|---|---|---|---|
| Open diagnostic float | `<leader>ds` | ❌ | ❌ | ❌ |
| Trigger completion (insert mode) | `<leader>cc` | ❌ | ❌ | ❌ |
| Format buffer | `<leader>cf` | ❌ | ❌ | ❌ |
| Navigate completion popup (insert mode) | `<C-j>` / `<C-k>` | ❌ | ❌ | ❌ |

### Shell (zsh)

`functions/vi-mode.zsh` enables zsh's vi line-editing mode (`bindkey -v`),
independent of the tools above — it applies to any zsh prompt, including inside
tmux/herdr panes.

| Action | Key |
|---|---|
| Enter normal (vi command) mode | `jk` (from insert mode) |
| Edit command line in `$EDITOR` | `v` (from normal mode) |
