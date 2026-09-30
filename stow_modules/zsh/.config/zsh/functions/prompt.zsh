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

_prompt_git_update() {
  _PROMPT_GIT_COLOR=""
  _PROMPT_GIT_STATUS=""

  local output
  output=$(command git status --porcelain=v2 --branch 2>/dev/null) || return

  local line xy dirty=0 ahead=0 behind=0
  local added=0 modified=0 deleted=0 renamed=0 unmerged=0 untracked=0
  for line in "${(@f)output}"; do
    case $line in
      '# branch.ab '*)
        local ab=(${=line})
        ahead=${ab[3]#+}
        behind=${ab[4]#-}
        continue
        ;;
      '#'*) continue ;;
      '? '*) untracked=1 ;;
      'u '*) unmerged=1 ;;
      [12]' '*)
        xy=${line[3,4]}
        [[ ${xy[1]} == [AM] ]] && added=1
        [[ ${xy[2]} == [MT] ]] && modified=1
        [[ $xy == *D* ]] && deleted=1
        [[ ${xy[1]} == R ]] && renamed=1
        ;;
    esac
    dirty=1
  done

  if (( dirty || ahead || behind )); then
    _PROMPT_GIT_COLOR="%F{#f7768e}"
  else
    _PROMPT_GIT_COLOR="%F{#9ece6a}"
  fi

  local s=""
  (( behind )) && s+=$ZSH_THEME_GIT_PROMPT_BEHIND
  (( ahead )) && s+=$ZSH_THEME_GIT_PROMPT_AHEAD
  (( unmerged )) && s+=$ZSH_THEME_GIT_PROMPT_UNMERGED
  command git rev-parse --verify --quiet refs/stash >/dev/null && s+=$ZSH_THEME_GIT_PROMPT_STASHED
  (( deleted )) && s+=$ZSH_THEME_GIT_PROMPT_DELETED
  (( renamed )) && s+=$ZSH_THEME_GIT_PROMPT_RENAMED
  (( modified )) && s+=$ZSH_THEME_GIT_PROMPT_MODIFIED
  (( added )) && s+=$ZSH_THEME_GIT_PROMPT_ADDED
  (( untracked )) && s+=$ZSH_THEME_GIT_PROMPT_UNTRACKED
  [[ -n $s ]] && _PROMPT_GIT_STATUS=" [ $s]"
}

_prompt_git_branch() {
  autoload -Uz vcs_info
  setopt prompt_subst
  zstyle ':vcs_info:git:*' formats '%b'
}

_prompt_precmd() {
  # Pass a line before each prompt
  print -P ''
  vcs_info
  _prompt_git_update
  _PROMPT_GIT_INFO=""
  [[ -n $vcs_info_msg_0_ ]] && _PROMPT_GIT_INFO="${_PROMPT_GIT_COLOR}${ZSH_THEME_GIT_PROMPT_PREFIX}%F{#c0caf5}${vcs_info_msg_0_}%f"
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

  ZSH_THEME_GIT_PROMPT_PREFIX=$'\u03bb%f:'
  ZSH_THEME_GIT_PROMPT_DIRTY=""
  ZSH_THEME_GIT_PROMPT_CLEAN=""

  ZSH_THEME_GIT_PROMPT_ADDED="%F{#9ece6a}+%f "
  ZSH_THEME_GIT_PROMPT_MODIFIED=$'%F{#7aa2f7}\u2605%f '
  ZSH_THEME_GIT_PROMPT_DELETED="%F{#f7768e}x%f "
  ZSH_THEME_GIT_PROMPT_RENAMED=$'%F{#bb9af7}\u279c%f '
  ZSH_THEME_GIT_PROMPT_UNMERGED="%F{#e0af68}=%f "
  ZSH_THEME_GIT_PROMPT_UNTRACKED=$'%F{#c0caf5}\u25cf%f '
  ZSH_THEME_GIT_PROMPT_STASHED=$'%B%F{#f7768e}\u2757%f%b '
  ZSH_THEME_GIT_PROMPT_BEHIND=$'%B%F{#f7768e}\u2193%f%b '
  ZSH_THEME_GIT_PROMPT_AHEAD=$'%B%F{#9ece6a}\u2191%f%b '

  _prompt_git_branch
  #  RPROMPT='${_PROMPT_GIT_INFO} ${_PROMPT_GIT_STATUS} %*'
  PROMPT=$'%F{#c0caf5}%n%f@%F{#7aa2f7}%m:%F{#c0caf5}%~ ${_PROMPT_GIT_INFO} ${_PROMPT_GIT_STATUS}\n%B%F{#7aa2f7}>%f%b '
}

_prompt_setup
