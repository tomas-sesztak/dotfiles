---
name: cleanup-agents
description: Close windows/workspaces for finished worktree agents. Use to tidy up done/idle agent sessions.
model: haiku
disable-model-invocation: true
---

# Cleanup Agents

Script do work. Skill just run it and report.

## 1. Run script

```sh
zsh -ic 'cleanup-agents'
```

## 2. Report

Report what was closed/removed (or that nothing was closed) from the
script's output. No dry-run, no confirmation step — the script only closes
agents that are already idle/done with a clean worktree.
