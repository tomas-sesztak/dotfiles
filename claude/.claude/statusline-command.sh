#!/bin/bash
# Status line, two lines:
#   1) [model name] git-repo | git-branch
#   2) 5h and 7-day Claude.ai rate-limit usage as progress bars + percentages
# Colors are dimmed by Claude Code's renderer, so plain ANSI codes are used here.

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name')
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
repo=$(echo "$input" | jq -r '.workspace.repo | if . then .owner + "/" + .name else empty end')
[ -z "$repo" ] && repo=$(basename "$cwd")

branch=""
if git -C "$cwd" --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null \
    || git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
fi

printf "\033[1;37m[%s]\033[0m \033[34m%s\033[0m" "$model" "$repo"
[ -n "$branch" ] && printf " \033[90m|\033[0m \033[32m%s\033[0m" "$branch"

bar() {
  local pct width filled empty color
  pct=$(printf '%.0f' "$1")
  width=10
  filled=$((pct * width / 100))
  [ "$filled" -gt "$width" ] && filled=$width
  empty=$((width - filled))

  if [ "$pct" -ge 90 ]; then
    color="31" # red
  elif [ "$pct" -ge 70 ]; then
    color="33" # yellow
  else
    color="32" # green
  fi

  printf "\033[%sm" "$color"
  [ "$filled" -gt 0 ] && printf '%0.s█' $(seq 1 "$filled")
  printf "\033[90m"
  [ "$empty" -gt 0 ] && printf '%0.s░' $(seq 1 "$empty")
  printf "\033[0m %s%%" "$pct"
}

five=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

if [ -n "$five" ] || [ -n "$week" ]; then
  printf "\n"
  [ -n "$five" ] && { printf "\033[90m5h \033[0m"; bar "$five"; }
  [ -n "$five" ] && [ -n "$week" ] && printf "  "
  [ -n "$week" ] && { printf "\033[90m7d \033[0m"; bar "$week"; }
fi
