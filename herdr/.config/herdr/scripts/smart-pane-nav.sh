#!/bin/sh
set -eu
dir="$1"
case "$dir" in
  left)  key=ctrl+h ;;
  down)  key=ctrl+j ;;
  up)    key=ctrl+k ;;
  right) key=ctrl+l ;;
esac

info=$(herdr pane process-info --current)
name=$(printf '%s' "$info" | jq -r '.result.process_info.foreground_processes[-1].name // empty')

if printf '%s' "$name" | grep -iqE '^g?(view|n?vim?x?)(diff)?$'; then
  pane_id=$(herdr pane current --current | jq -r '.result.pane.pane_id')
  herdr pane send-keys "$pane_id" "$key"
else
  herdr pane focus --direction "$dir"
fi
