function _agent-sanitize-name {
	local name="${1:l}"
	name="${name//[^a-z0-9_-]/-}"
	while [[ -n "$name" && "$name" != [a-z]* ]]; do
		name="${name#?}"
	done
	name="${name:0:32}"
	[ -z "$name" ] && name="agent"
	print -r -- "$name"
}
