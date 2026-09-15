---
name: init-agents
description: Start agent in every repo under a path. Use for bulk-launch agents across sibling repos.
model: haiku
disable-model-invocation: true
---

# Init Agents

Script do work. Skill just pick agent and path.

## 1. Pick agent (AskUserQuestion)

- **claude**
- **copilot**

("Other" covers any other agent name.)

## 2. Pick path (AskUserQuestion)

- **Parent of current repo** — show in description:
  ```sh
  dirname "$(git worktree list | head -1 | awk '{print $1}')"
  ```
- **Enter a path myself** — ask user for literal path.

## 3. Run script

```sh
zsh -ic 'init-agents -a "$1" -p "$2"' _ "<agent>" "<path>"
```

Done. No report, no return-code check.
