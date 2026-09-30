#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
MODULES_DIR="$SCRIPT_DIR/stow_modules"

usage() {
	echo "Usage: $(basename "$0") [deploy|undeploy] [--no-claude] [--adopt]" >&2
	echo "  deploy      - stow all packages into \$HOME (restow if already deployed)" >&2
	echo "  undeploy    - unstow all packages from \$HOME" >&2
	echo "  --no-claude - skip the claude package (avoids unlinking ~/.claude, e.g. during testing)" >&2
	echo "  --adopt     - deploy only: move existing conflicting files into the repo, then link (git checkout to restore repo versions)" >&2
}

action=""
no_claude=0
adopt=0
for arg in "$@"; do
	case "$arg" in
	--no-claude) no_claude=1 ;;
	--adopt) adopt=1 ;;
	deploy | undeploy)
		if [[ -n "$action" ]]; then
			usage
			exit 1
		fi
		action="$arg"
		;;
	*)
		usage
		exit 1
		;;
	esac
done

if [[ -z "$action" ]]; then
	usage
	exit 1
fi

if [[ "$adopt" -eq 1 && "$action" != "deploy" ]]; then
	usage
	exit 1
fi

case "$action" in
deploy) stow_flags=(-R) ;;
undeploy) stow_flags=(-D) ;;
esac
[[ "$adopt" -eq 1 ]] && stow_flags+=(--adopt)

if ! command -v stow &>/dev/null; then
	echo "Error: GNU Stow is not installed. Install it and re-run." >&2
	exit 1
fi

packages=()
for entry in "$MODULES_DIR"/*/; do
	name="$(basename "$entry")"
	[[ "$no_claude" -eq 1 && "$name" == "claude" ]] && continue
	packages+=("$name")
done

if [[ ${#packages[@]} -eq 0 ]]; then
	echo "No packages found in $MODULES_DIR; nothing to do."
	exit 0
fi

stow "${stow_flags[@]}" -t "$HOME" -d "$MODULES_DIR" "${packages[@]}"
echo "${action}ed: ${packages[*]}"
