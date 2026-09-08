---
name: fork-agent
description: Fork the current repo into a new git worktree and launch an agent there via the fork-agent zsh function. Use when the user wants to spin up a new agent/session, work in a worktree, or work on a GitHub issue, e.g. "fork a new agent", "start a session for this issue", "spawn an agent to plan X".
---

# Fork Agent

Wraps `fork-agent` (herdr/tmux detection, worktree creation live in the script). This
skill only picks the session **name** and optional **initial prompt** (`-w`, `-c`).

## 1. Pick mode (AskUserQuestion)

- **Name it myself** — free-text name, no `-c`.
- **Distill from planning prompt** — name it max 3 words kebab-case, `-c "/plan <prompt>"`.
- **Pick a GitHub issue** — `gh issue list --state open`; confirm/pick via
  AskUserQuestion. Name `issue-<number>_<kebab-title>`, `-c "Work on GitHub issue
  #<number>: <title>\n\n<body>"` (body from `gh issue view`).

Sanitize the name yourself to `[a-z0-9_-]` (lowercase, spaces → `-`) before passing it
as `-w` — the script only sanitizes its own derived agent identity, not the branch/
window name you give it.

## 2. Launch

```sh
zsh -ic 'fork-agent -a claude -w "$1" ${2:+-c "$2"}' _ "<name>" "<command-or-empty>"
```

Default agent: `claude`. Report the script's output (worktree path / tmux window /
herdr pane) to the user.
