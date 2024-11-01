# Setup

## GNU-Stow
Install GNU-stow
```bash
brew install stow
```

Symlink all configuration to homedir from this git repo
```bash
stow --adopt .
```

## Zsh
Relaunch zsh to use new ~/.zshrc

## Brew dependencies
```bash
brew_update
```

## Tmux
Install tpm
```bash
tmux_initialize_tpm
```

Then install plugins from within tmux
> \<prefix\> + I

## Neovim

### Neovim plugins
Open Lazy and let it update
> \<Prefix\> + L

### Mason plugins
Open Mason and let it update
> \<Prefix\> + M
