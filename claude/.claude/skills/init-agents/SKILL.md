---
name: init-agents
description: Ensure a window/workspace with an agent running exists for every top-level git repo under a path, via the init-agents zsh function. Use when the user wants to bulk-launch agents across sibling repos, e.g. "spin up agents for all my repos", "init agents under ~/worktrees".
---

# Init Agents

Wraps the `init-agents` zsh function — multiplexer detection (herdr vs tmux) and the
per-repo loop live in the script. This skill only picks the **agent** and the **path**.

## 1. Pick agent (AskUserQuestion)

- **claude**
- **copilot**

(The tool's automatic "Other" choice covers any other agent/command name.)

## 2. Pick path (AskUserQuestion)

- **Parent of current repo** — compute and show in the option description:
  ```sh
  dirname "$(git worktree list | head -1 | awk '{print $1}')"
  ```
  (`git worktree list`'s first line is always the main checkout, even when run from a
  linked worktree)
- **Enter a path myself** — if chosen, ask the user directly for the literal path.

## 3. Launch

```sh
zsh -ic 'init-agents -a "$1" -p "$2"' _ "<agent>" "<path>"
```

Report the function's output (which windows/workspaces got created, if any) to the user.
