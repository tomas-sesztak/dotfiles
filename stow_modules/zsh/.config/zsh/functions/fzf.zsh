function fd {
	local findPath="${1:-.}"
	local dir
	dir="$(find "${findPath}" -type d 2>/dev/null |grep -v -e '\.git' |fzf -i --border=rounded --preview 'ls -ltrh {}')"
	[ -n "$dir" ] || return 0
	cd "$dir"
}

function ff {
	local findPath="${1:-.}"
	local file
	file="$(find "${findPath}" -type f 2>/dev/null |grep -v -e '\.git' |fzf -i --border=rounded --preview 'less {}')"
	[ -n "$file" ] && "$EDITOR" "$file"
}

function fs {
  local findPath="${1:-.}"
  local file
  file="$(rg --line-number --no-heading --color=never --smart-case $findPath | fzf -i --border=rounded |cut -d: -f1)"
  [ -n "$file" ] && "$EDITOR" "$file"
}

# Enable fzf for zsh (keybindings need a real terminal for zle)
[[ -t 1 ]] && eval "$(fzf --zsh)"

