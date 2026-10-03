# Absolute git common dir: same for a main checkout and all its worktrees
function _git-repo-key {
	command git -C "${1:-.}" rev-parse --path-format=absolute --git-common-dir 2>/dev/null
}
