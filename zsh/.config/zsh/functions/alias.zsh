# ensure ls support colors
alias ls="ls --color"
alias ll="ls -la"

# tree shows all files
alias tree="tree -a -I '.git'"

# git
alias ga="git add"
alias ga.="git add ."
alias gae="git add -e"
alias gae.="git add -e ."
alias gap="git add -p"
alias gap.="git add -p ."

alias gc="git commit -m"

alias gs="git status"

alias gd="git diff"
alias gds="git diff --staged"

alias gp="git push"

# tmux
alias tmux="tmux attach -t ${USER} || tmux new -s ${USER}"
