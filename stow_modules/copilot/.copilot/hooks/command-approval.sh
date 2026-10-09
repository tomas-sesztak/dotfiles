#!/usr/bin/env bash
# Copilot CLI preToolUse hook for the `bash` tool.
# Any segment matching ASK_RULES -> "ask"; every segment matching ALLOW_RULES -> "allow";
# otherwise no output, leaving Copilot's default permission handling in place.
# Must always exit 0: preToolUse hooks fail closed (non-zero denies the call).

# `cmd` alone: always ask. `cmd: w...`: ask if any later word glob-matches one of w.
ASK_RULES='
ssh
scp
sftp
rsync
sudo
su
doas
rm
rmdir
shred
dd
mkfs
kill
pkill
killall
shutdown
reboot
poweroff
chmod
chown
chgrp
npx
pipx
eval
aws
gcloud
az
git: push reset clean rm restore rebase filter-branch filter-repo gc prune update-ref drop clear -D -d --delete --force --force-with-lease
gh: create merge close reopen delete edit comment review api secret variable release workflow archive transfer lock
kubectl: apply create delete edit patch replace scale rollout drain cordon uncordon taint label annotate exec cp port-forward proxy set run expose autoscale debug attach secret secrets
oc: apply create delete edit patch replace scale rollout drain cordon uncordon taint label annotate exec cp port-forward proxy set run expose autoscale debug attach secret secrets new-app new-project new-build start-build cancel-build adm login logout process import-image tag rsh rsync policy
helm: install upgrade uninstall delete rollback push add remove plugin
brew: install uninstall remove rm reinstall upgrade update link unlink tap untap cleanup autoremove services bundle pin unpin
npm: install i ci add uninstall remove rm un update up upgrade publish unpublish deprecate link exec x run run-script start restart stop
pnpm: install i add remove rm update up publish link exec dlx run
yarn: install add remove upgrade up publish link dlx run
pip: install uninstall download
pip3: install uninstall download
uv: add remove sync pip run tool publish
podman: rm rmi prune run exec push kill stop restart down login logout volume network system
docker: rm rmi prune run exec push kill stop restart down login logout volume network system
systemctl: start stop restart reload enable disable mask unmask kill daemon-reload
dnf: install remove erase update upgrade reinstall autoremove downgrade
yum: install remove erase update upgrade reinstall autoremove downgrade
apt: install remove purge update upgrade full-upgrade autoremove
apt-get: install remove purge update upgrade dist-upgrade autoremove
rpm-ostree: install uninstall upgrade rebase rollback deploy override reset
flatpak: install uninstall update remove
terraform: apply destroy import state taint untaint
tofu: apply destroy import state taint untaint
find: -delete -exec -execdir -ok -okdir -fprint -fprint0 -fprintf -fls
sed: -i* --in-place*
sort: -o* --output*
curl: -X --request -d* --data* -F --form -T --upload-file
tmux: kill-*
'

# `prefix...:` alone: allow any args. `prefix...: w...`: allow if the next positional arg is one of w.
ALLOW_RULES='
ls:
cat:
head:
tail:
grep:
egrep:
rg:
fd:
find:
wc:
sort:
cut:
tr:
diff:
cmp:
file:
stat:
du:
df:
pwd:
cd:
echo:
printf:
which:
type:
whoami:
id:
hostname:
uname:
date:
basename:
dirname:
realpath:
readlink:
tree:
jq:
yq:
column:
nl:
tac:
rev:
comm:
true:
false:
test:
shellcheck:
git: status log diff show branch rev-parse ls-files ls-tree blame describe shortlog remote fetch grep cat-file merge-base show-ref for-each-ref reflog
gh pr: view list diff checks status
gh issue: view list status
gh repo: view list
gh run: view list
gh release: view list
gh: status search
kubectl: get describe logs explain api-resources api-versions version top
kubectl config: view get-contexts current-context
oc: get describe logs explain api-resources api-versions version whoami status projects project
helm: list ls status get history show search template version
brew: list ls info search outdated deps uses leaves config doctor --version
npm: ls list view info outdated why explain config --version
pip: list show freeze check --version
pip3: list show freeze check --version
podman: ps images inspect logs version info
docker: ps images inspect logs version info
systemctl: status list-units list-unit-files is-active is-enabled cat show
'

WRAPPERS=' env nohup nice time timeout command xargs watch '

set -f
input=$(cat)
command -v jq >/dev/null || exit 0
[[ $(jq -r '.toolName // empty' <<<"$input" 2>/dev/null) == bash ]] || exit 0
cmd=$(jq -r '.toolArgs | (if type == "string" then (fromjson? // {}) else . end) | .command // empty' <<<"$input" 2>/dev/null)
[[ -n $cmd ]] || exit 0

decide() {
	printf '{"permissionDecision":"%s","permissionDecisionReason":"%s"}\n' "$1" "$2"
	exit 0
}

# Prints the words of a segment from the real command onward (env assignments and wrappers stripped).
strip_wrappers() {
	local -a w=("$@")
	local i=0
	while ((i < ${#w[@]})); do
		local word=${w[i]}
		if [[ $word == *=* && $word != -* ]]; then
			((i++))
		elif [[ $WRAPPERS == *" ${word##*/} "* ]]; then
			((i++))
			while ((i < ${#w[@]})) && [[ ${w[i]} == -* || ${w[i]} == *=* || ${w[i]} =~ ^[0-9.]+[smhd]?$ ]]; do ((i++)); done
		else
			break
		fi
	done
	printf '%s\n' "${w[@]:i}"
}

is_ask() {
	local -a w=("$@")
	local base=${w[0]##*/} rule name pat word
	while read -r rule; do
		[[ -n $rule ]] || continue
		name=${rule%%:*}
		[[ $name == "$base" ]] || continue
		[[ $rule == *:* ]] || return 0
		for pat in ${rule#*:}; do
			for word in "${w[@]:1}"; do
				# shellcheck disable=SC2053
				[[ $word == $pat ]] && return 0
			done
		done
	done <<<"$ASK_RULES"
	return 1
}

is_allowed() {
	local -a w=("$@")
	local -a pos=("${w[0]##*/}")
	local word rule prefix subs next
	for word in "${w[@]:1}"; do [[ $word == -* ]] || pos+=("$word"); done
	while read -r rule; do
		[[ -n $rule ]] || continue
		prefix=${rule%%:*}
		subs=${rule#*:}
		local -a pw
		read -ra pw <<<"$prefix"
		[[ ${pos[*]:0:${#pw[@]}} == "${pw[*]}" ]] || continue
		[[ -z ${subs// /} ]] && return 0
		# Subcommand may be a flag (e.g. `brew --version`), so check the first raw word too.
		next=${pos[${#pw[@]}]:-${w[${#pw[@]}]:-}}
		[[ " $subs " == *" $next "* ]] && return 0
	done <<<"$ALLOW_RULES"
	return 1
}

# Redirections to files and process/command substitution can't be auto-allowed.
sanitized=$(sed -E 's/[0-9]*>&[0-9-]//g; s#[0-9&]*>>? */dev/null##g' <<<"$cmd")
allowable=1
# shellcheck disable=SC2016
[[ $sanitized == *'>'* || $cmd == *'$('* || $cmd == *'`'* || $cmd == *'<('* ]] && allowable=0

segments=${cmd//\$(/;}
for sep in '&&' '||' '&' '|' '(' ')' '`' '{' '}'; do segments=${segments//"$sep"/;}; done
segments=${segments//;/$'\n'}

all_allowed=1
while IFS= read -r segment; do
	read -ra segment_words <<<"$segment"
	((${#segment_words[@]})) || continue
	words=()
	while IFS= read -r word; do words+=("$word"); done < <(strip_wrappers "${segment_words[@]}")
	((${#words[@]})) || continue
	is_ask "${words[@]}" && decide ask "Matches dangerous command rule: ${words[0]##*/}"
	is_allowed "${words[@]}" || all_allowed=0
done <<<"$segments"

((allowable && all_allowed)) && decide allow "All commands match safe rules"
exit 0
