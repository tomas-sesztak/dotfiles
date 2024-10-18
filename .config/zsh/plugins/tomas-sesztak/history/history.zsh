# location of the history file
HISTFILE=~/.zsh_history
# history limit of the file on disk
HISTFILESIZE=10000
# current session's history limit
HISTSIZE=10000
# zsh saves this many lines from the in-memory history list to the history file upon shell exit
SAVEHIST=10000
HISTTIMEFORMAT="%d/%m/%Y %H:%M] "

# history file is updated immediately after a command is entered
setopt INC_APPEND_HISTORY
# allows multiple Zsh sessions to share the same command history
setopt SHARE_HISTORY
# records the time when each command was executed along with the command itself
setopt EXTENDED_HISTORY
# ensures that each command entered in the current session is appended to the history file immediately after execution
setopt APPENDHISTORY
