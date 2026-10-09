#!/usr/bin/env bash
# Copilot CLI preToolUse hook: forces a user prompt ("ask") before destructive shell commands.
# Rules live in guard-destructive.rules next to this script.
# Prints nothing for safe commands, so the normal permission flow applies.
set -uo pipefail

rules_file="$(dirname "${BASH_SOURCE[0]}")/guard-destructive.rules"

ask() {
    jq -nc --arg r "guard-destructive: $1" '{permissionDecision: "ask", permissionDecisionReason: $r}'
    exit 0
}

if ! command -v jq >/dev/null 2>&1; then
    printf '{"permissionDecision":"ask","permissionDecisionReason":"guard-destructive: jq missing, cannot inspect command"}\n'
    exit 0
fi

# toolArgs may arrive as an object or a JSON-encoded string
cmd=$(jq -r '.toolArgs | (if type == "string" then (fromjson? // .) else . end) | .command? // empty' 2>/dev/null)
[[ -z "$cmd" ]] && exit 0

[[ -r "$rules_file" ]] || ask "rules file missing: $rules_file"

sep=' :: '
while IFS= read -r line || [[ -n "$line" ]]; do
    [[ "$line" =~ ^[[:space:]]*(#|$) ]] && continue
    [[ "$line" == *"$sep"*"$sep"* ]] || ask "malformed rule: $line"

    flags=${line%%"$sep"*};   rest=${line#*"$sep"}
    label=${rest%%"$sep"*};   rest=${rest#*"$sep"}
    pattern=${rest%%"$sep"*}; unless=""
    [[ "$rest" == *"$sep"* ]] && unless=${rest#*"$sep"}
    read -r flags <<<"$flags"; read -r label <<<"$label"
    read -r pattern <<<"$pattern"; read -r unless <<<"$unless"

    opts=(-Eq); [[ "$flags" == *i* ]] && opts=(-Eiq)
    grep "${opts[@]}" -- "$pattern" <<<"$cmd" || continue
    [[ -n "$unless" ]] && grep "${opts[@]}" -- "$unless" <<<"$cmd" && continue
    ask "$label"
done <"$rules_file"

exit 0
