---
name: fork-agent
description: Fork repo, start agent in new worktree. Use for new agent, new session, worktree, or GitHub issue.
model: haiku
disable-model-invocation: true
---

# Fork Agent

Figure out a session name and optional initial command from the user's request, then call:

```sh
zsh -ic 'fork-agent -a claude -w "$1" ${2:+-c "$2"}' _ "<name>" "<command-or-empty>"
```

All detection (herdr/tmux) and worktree creation live in the script. Report its output
(worktree path / tmux window / herdr pane) to the user.
