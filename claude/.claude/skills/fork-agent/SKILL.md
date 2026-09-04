---
name: fork-agent
description: Fork the current repo into a new git worktree and launch an agent there via the fork-agent zsh script, naming the session by direct input, a distilled planning prompt, or a picked GitHub issue. Use when the user wants to spin up a new agent/session in a worktree, e.g. "fork a new agent", "start a session for this issue", "spawn an agent to plan X".
---

# Fork Agent

Wraps the `fork-agent` zsh function — fork/launch mechanics (herdr vs tmux, worktree
creation) live in the script. This skill only picks the session **name** and optional
**initial prompt** (`-w`, `-c`).

## 1. Pick mode (AskUserQuestion)

- **Name it myself** — free-text name, no `-c`.
- **Distill from planning prompt** — free-text prompt → name it max 3 words,
  kebab-case, `-c "/plan <prompt>"`.
- **Pick a GitHub issue** — `gh issue list --state open`. One issue: confirm via
  AskUserQuestion. Multiple: pick via AskUserQuestion. Name `<number>_<kebab-title>`,
  `-c "Work on GitHub issue #<number>: <title>\n\n<body>"` (body from `gh issue view`).

Sanitize any name to `[a-z0-9-]` (lowercase, spaces/underscores → `-`).

## 2. Launch

```sh
zsh -ic 'fork-agent -a claude -w "$1" ${2:+-c "$2"}' _ "<name>" "<command-or-empty>"
```

Default agent: `claude`. Report the script's output (worktree path / tmux window /
herdr pane) to the user.
