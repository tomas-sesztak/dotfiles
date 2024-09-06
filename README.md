# Setup
## Zsh and prerequisities
Install using preferred package manager
- zsh
- antigen (zsh bundle manager)
- tmux
- NerdFonts, for example [these](https://github.com/romkatv/powerlevel10k#meslo-nerd-font-patched-for-powerlevel10k)
> brew install zsh antigen tmux

Clone the repository into $HOME but keep dotfiles separate, for example:
> cd ~
> git init --separate-git-dir=.dotfiles
> git remote add origin git@github.com:tomas-sesztak/dotfiles.git

Then launch zsh, setup should be automatic

## Tmux
Install tpm
> git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

Then install plugins from within tmux
> \<prefix\>+I (capital i)
