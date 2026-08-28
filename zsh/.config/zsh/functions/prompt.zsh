# RPROMPT doesn't save to history
setopt transient_rprompt

# prompt:
# %F => color dict
# %f => reset color
# %~ => current path
# %* => time
# %n => username
# %m => shortname host
# %(?..) => prompt conditional - %(condition.true.false)

_git_prompt_status() {
  local INDEX STATUS

  INDEX=$(command git status --porcelain -b 2> /dev/null)

  STATUS=""

  if $(echo "$INDEX" | command grep -E '^\?\? ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_UNTRACKED$STATUS"
  fi

  if $(echo "$INDEX" | grep '^A  ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_ADDED$STATUS"
  elif $(echo "$INDEX" | grep '^M  ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_ADDED$STATUS"
  elif $(echo "$INDEX" | grep '^MM ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_ADDED$STATUS"
  fi

  if $(echo "$INDEX" | grep '^ M ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_MODIFIED$STATUS"
  elif $(echo "$INDEX" | grep '^AM ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_MODIFIED$STATUS"
  elif $(echo "$INDEX" | grep '^MM ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_MODIFIED$STATUS"
  elif $(echo "$INDEX" | grep '^ T ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_MODIFIED$STATUS"
  fi

  if $(echo "$INDEX" | grep '^R  ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_RENAMED$STATUS"
  fi

  if $(echo "$INDEX" | grep '^ D ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_DELETED$STATUS"
  elif $(echo "$INDEX" | grep '^D  ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_DELETED$STATUS"
  elif $(echo "$INDEX" | grep '^AD ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_DELETED$STATUS"
  fi

  if $(command git rev-parse --verify refs/stash >/dev/null 2>&1); then
    STATUS="$ZSH_THEME_GIT_PROMPT_STASHED$STATUS"
  fi

  if $(echo "$INDEX" | grep '^UU ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_UNMERGED$STATUS"
  fi

  if $(echo "$INDEX" | grep '^## [^ ]\+ .*ahead' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_AHEAD$STATUS"
  fi

  if $(echo "$INDEX" | grep '^## [^ ]\+ .*behind' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_BEHIND$STATUS"
  fi

  if $(echo "$INDEX" | grep '^## [^ ]\+ .*diverged' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_DIVERGED$STATUS"
  fi

  if [[ ! -z "$STATUS" ]]; then
    echo " [ $STATUS]"
  fi
}


_prompt_git_branch() {
  autoload -Uz vcs_info
  precmd_vcs_info() { vcs_info }
  precmd_functions+=( precmd_vcs_info )
  setopt prompt_subst
  zstyle ':vcs_info:git:*' formats '%b'
}

_prompt_git_status_color() {
  # Check if we are in a git repo
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    ZSH_THEME_GIT_PROMPT_PREFIX_COLOR=""
    return
  fi

  # 1. Check for local changes (Modified, Added, Deleted, etc.)
  local dirty=$(git status --porcelain 2>/dev/null)

  # 2. Check for remote sync (Ahead/Behind)
  # This counts commits between local and upstream
  local ahead_behind=$(git rev-list --count --left-right @{u}...HEAD 2>/dev/null)

  # Logic: If 'dirty' is not empty OR 'ahead_behind' contains any number > 0
  if [[ -n "$dirty" ]] || [[ "$ahead_behind" =~ [1-9] ]]; then
    ZSH_THEME_GIT_PROMPT_PREFIX_COLOR="%F{red}" # Red if changes exist
  else
    ZSH_THEME_GIT_PROMPT_PREFIX_COLOR="%F{green}" # Green if totally clean/synced
  fi
}

_prompt_git_info() {
  _prompt_git_status_color
  [ ! -z "$vcs_info_msg_0_" ] && echo "${ZSH_THEME_GIT_PROMPT_PREFIX_COLOR}$ZSH_THEME_GIT_PROMPT_PREFIX%F{white}$vcs_info_msg_0_%f$ZSH_THEME_GIT_PROMPT_SUFFIX"
}

_prompt_precmd() {
  # Pass a line before each prompt
  print -P ''
  _prompt_git_status_color
}

_prompt_setup() {
  # Symbols
  # \u03bb Lambda
  # \u2605 Star
  # \u279c Right Arrow
  # \u2191 Up Arrow
  # \u2193 Down Arrow
  # \u2757 Heavy Exclamation Mark
  # \u25cf Large Circle Dot

  # Display git branch

  autoload -Uz add-zsh-hook
  add-zsh-hook precmd _prompt_precmd

  ZSH_THEME_GIT_PROMPT_PREFIX="\u03bb%f:"
  ZSH_THEME_GIT_PROMPT_DIRTY=""
  ZSH_THEME_GIT_PROMPT_CLEAN=""

  ZSH_THEME_GIT_PROMPT_ADDED="%F{green}+%f "
  ZSH_THEME_GIT_PROMPT_MODIFIED="%F{blue}\u2605%f "
  ZSH_THEME_GIT_PROMPT_DELETED="%F{red}x%f "
  ZSH_THEME_GIT_PROMPT_RENAMED="%F{magenta}\u279c%f "
  ZSH_THEME_GIT_PROMPT_UNMERGED="%F{yellow}=%f "
  ZSH_THEME_GIT_PROMPT_UNTRACKED="%F{white}\u25cf%f "
  ZSH_THEME_GIT_PROMPT_STASHED="%B%F{red}\u2757%f%b "
  ZSH_THEME_GIT_PROMPT_BEHIND="%B%F{red}\u2193%f%b "
  ZSH_THEME_GIT_PROMPT_AHEAD="%B%F{green}\u2191%f%b "

  _prompt_git_branch
  RPROMPT='$(_prompt_git_info) $(_git_prompt_status) %*'
  PROMPT=$'%F{white}%n%f@%F{blue}%m:%F{white}%~\n%B%F{blue}>%f%b '
}

_prompt_setup

