#!/bin/bash

# Scripts Edit
function se() {
  local findPath="${1:-.}"
  local file="$(find "${findPath}" -type f 2>/dev/null |grep -v -e '\.git' |fzf -i --border=rounded --preview 'less {}')"
  [ -n "$file" ] && vim "$file"
}

# Find directory
function fd() {
  local findPath="${1:-.}"
  local path="$(find "${findPath}" -type d 2>/dev/null |grep -v -e '\.git' |fzf -i --border=rounded)"
  [ -n "$path" ] && cd "$path"
}

