#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

usage() {
	echo "Usage: $(basename "$0") [deploy|undeploy]" >&2
	echo "  deploy    - stow all packages into \$HOME (restow if already deployed)" >&2
	echo "  undeploy  - unstow all packages from \$HOME" >&2
}

if [[ $# -ne 1 ]]; then
	usage
	exit 1
fi

action="$1"
case "$action" in
deploy) stow_flag="-R" ;;
undeploy) stow_flag="-D" ;;
*)
	usage
	exit 1
	;;
esac

if ! command -v stow &>/dev/null; then
	echo "Error: GNU Stow is not installed. Install it and re-run." >&2
	exit 1
fi

packages=()
for entry in "$SCRIPT_DIR"/*/; do
	name="$(basename "$entry")"
	[[ "$name" == ".git" ]] && continue
	packages+=("$name")
done

if [[ ${#packages[@]} -eq 0 ]]; then
	echo "No packages found in $SCRIPT_DIR; nothing to do."
	exit 0
fi

stow "$stow_flag" -t "$HOME" -d "$SCRIPT_DIR" "${packages[@]}"
echo "${action}ed: ${packages[*]}"
