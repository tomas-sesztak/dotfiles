#!/usr/bin/env bash
# shellcheck source=lib.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/lib.sh"

GUARD="$MODULES/copilot/.copilot/hooks/guard-destructive.sh"
RULES="$MODULES/copilot/.copilot/hooks/guard-destructive.rules"

verdict() {
	jq -r '.permissionDecision // empty' <<<"$1"
}

check() {
	local expect=$1 cmd=$2 output decision
	output=$(jq -nc --arg c "$cmd" '{toolArgs: {command: $c}}' | "$GUARD")
	decision=$(verdict "$output")
	assert_eq "$cmd" "$expect" "${decision:-allow}"
}

while read -r expect cmd; do
	[[ -z "$expect" || "$expect" == \#* ]] && continue
	check "$expect" "$cmd"
done <<'CASES'
ask find . -delete
ask find . -name '*.log' -delete
ask git push --force
ask git push origin main --force-with-lease
ask git push -f origin main
ask git push origin +main
ask /usr/bin/oc delete pod x
ask kubectl -n x delete pod y
ask kubectl delete --dry-run=client pod x
ask oc adm drain node1
ask kubectl drain node1
ask kubectl replace -f x.yaml
ask kubectl apply -f x.yaml
ask kubectl apply --dry-run=client --prune -f x.yaml
ask oc scale --replicas=0 dc/x
ask kubectl rollout restart deploy/x
ask kubectl exec -it x -- sh
ask oc rsh x
ask kubectl create rolebinding x
ask kubectl certificate approve x
ask kubectl config use-context prod
ask oc login https://example.com
ask oc project prod
ask oc get secret x -o yaml
ask oc extract secret/x
ask kubectl label pod x a=b
ask kubectl apply --dry-run=client -f x; oc delete pod y
ask kubectl apply --dry-run=client -f x && kubectl apply -f x

allow ls -la
allow git push
allow git push origin main
allow find . -name delete
allow oc get pods
allow oc -n prod get pods
allow kubectl get pods -n delete
allow kubectl get secrets
allow kubectl config get-contexts
allow kubectl rollout status deploy/x
allow kubectl apply --dry-run=client -f x
allow kubectl create deployment x --image=y --dry-run=server
allow oc scale --dry-run=client --replicas=1 dc/x
allow oc adm top nodes
allow oc policy who-can get pods
CASES

output=$(jq -nc '{toolArgs: {command: "oc delete pod x"}}' | "$GUARD")
assert_contains "label in reason" "k8s delete" "$(jq -r .permissionDecisionReason <<<"$output")"

output=$(jq -nc --arg a '{"command":"oc delete pod x"}' '{toolArgs: $a}' | "$GUARD")
assert_eq "toolArgs as JSON string" ask "$(verdict "$output")"

assert_eq "no command prints nothing" "" "$(jq -nc '{toolArgs: {}}' | "$GUARD")"
assert_eq "other tool args print nothing" "" "$("$GUARD" <<<'{"toolArgs":{"path":"x"}}')"
assert_eq "empty command prints nothing" "" "$("$GUARD" <<<'{"toolArgs":{"command":""}}')"

for bad in 'not json' '' '[]' '{"toolArgs":"not json"}'; do
	output=$(printf '%s' "$bad" | "$GUARD")
	assert_eq "unparsable input asks: '$bad'" ask "$(verdict "$output")"
	assert_contains "unparsable input reason: '$bad'" "cannot parse hook input" "$output"
done

copy="$SANDBOX/guard"
mkdir "$copy"
cp "$GUARD" "$copy/"
input='{"toolArgs":{"command":"ls"}}'

output=$("$copy/guard-destructive.sh" <<<"$input")
assert_eq "missing rules asks" ask "$(verdict "$output")"
assert_contains "missing rules reason" "rules file missing" "$output"

printf 'not a rule\n' >"$copy/guard-destructive.rules"
output=$("$copy/guard-destructive.sh" <<<"$input")
assert_eq "malformed rule asks" ask "$(verdict "$output")"
assert_contains "malformed rule reason" "malformed rule" "$output"

cp "$RULES" "$copy/"
path_dir="$SANDBOX/nojq"
mkdir "$path_dir"
ln -s "$(command -v dirname)" "$path_dir/dirname"
output=$(PATH="$path_dir" "$(command -v bash)" "$copy/guard-destructive.sh" <<<"$input")
assert_eq "missing jq asks" ask "$(verdict "$output")"
assert_contains "missing jq reason" "jq missing" "$output"
