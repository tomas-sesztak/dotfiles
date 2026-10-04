# dotfiles

Personal dotfiles, deployed to `$HOME` with [GNU Stow](https://www.gnu.org/software/stow/).
Each top-level directory under `stow_modules/` is an auto-discovered Stow package
mirroring its target layout (e.g. `stow_modules/nvim/.config/nvim/` → `~/.config/nvim`).

## Getting started

Requires GNU Stow.

```sh
./setup.sh deploy      # stow all packages into $HOME (safe to re-run)
./setup.sh undeploy    # remove all symlinks from $HOME
```

## Packages

| Package | Deploys to | Notes |
|---|---|---|
| `bash/` | `~/.bashrc` | Single file; `.bash_profile`, `.bash_logout` and `.bash_history` left unmanaged. |
| `claude/` | `~/.claude` | Config, hooks and skills tracked; runtime/secret state excluded via `.gitignore` allowlist. |
| `copilot/` | `~/.copilot` | Whole directory tracked; `copilot-instructions.md` symlinks to Claude's `CLAUDE.md`. |
| `herdr/` | `~/.config/herdr` | Config and scripts tracked; runtime state excluded via `.gitignore` allowlist. |
| `homebrew/` | `~/.Brewfile` | Single file (`brew bundle --global` default); sync Homebrew to it with `brew_update`. |
| `nvim/` | `~/.config/nvim` | Whole directory tracked. |
| `tmux/` | `~/.tmux.conf`, `~/.tmux` | Whole directory tracked. |
| `vim/` | `~/.vimrc`, `~/.vim` | Whole directory tracked. |
| `zsh/` | `~/.config/zsh/{functions,completions}` | Whole directory tracked; `~/.zshrc` stays user-owned — `setup.sh deploy` appends a `source …/functions/init/init.zsh` line to it. Regenerate completions with `generate_completions`. |

## Hotkeys

Leader (nvim, vim): `<Space>`. Prefix (tmux, herdr): `C-a`. ❌ = not supported/configured.

### Pane & window movement

Same keys everywhere; nvim, vim and herdr hand off to the neighbouring editor/multiplexer
pane at the split edge (vim: tmux only).

| Action | nvim | vim | tmux | herdr |
|---|---|---|---|---|
| Move focus left | `<C-h>` | `<C-h>` | `<C-h>` | `<C-h>` |
| Move focus down | `<C-j>` | `<C-j>` | `<C-j>` | `<C-j>` |
| Move focus up | `<C-k>` | `<C-k>` | `<C-k>` | `<C-k>` |
| Move focus right | `<C-l>` | `<C-l>` | `<C-l>` | `<C-l>` |

### Splits & panes

| Action | nvim | vim | tmux | herdr |
|---|---|---|---|---|
| Split vertically | `<leader>sv` | `<leader>sv` | `<prefix> v` | `<prefix> v` |
| Split horizontally | `<leader>sh` | `<leader>sh` | `<prefix> h` | `<prefix> h` |
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

vi line-editing mode (`bindkey -v`).

| Action | Key |
|---|---|
| Enter normal (vi command) mode | `jk` (from insert mode) |
| Edit command line in `$EDITOR` | `v` (from normal mode) |

Fuzzy commands (fzf; args default to `.`):

| Command | Action |
|---|---|
| `fd [path]` | Fuzzy-pick a directory and `cd` into it |
| `ff [path]` | Fuzzy-pick a file by name and open it in `$EDITOR` |
| `fs [pattern]` | Fuzzy-pick a line matching `pattern` (ripgrep) and open its file in `$EDITOR` |
