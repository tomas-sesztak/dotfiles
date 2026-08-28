function fd {
	local findPath="${1:-.}"
	local path="$(find "${findPath}" -type d 2>/dev/null |grep -v -e '\.git' |fzf -i --border=rounded --preview 'ls -ltrh {}')"
	[ -n "$path" ] && cd "$path" || exit 0
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

# Enable fzf for zsh
eval "$(fzf --zsh)"

