---
name: fix-issues
description: List open GitHub issues in repo, let user pick, fork an agent per pick. Use to bulk-start work on repo issues.
model: haiku
disable-model-invocation: true
---

# Fix Issues

gh list issues. You pick. Fork-agent skill do rest.

## 1. List open issues

```sh
gh issue list --json number,title,url --limit 50
```

No issues? Say so, stop.

## 2. Pick issues (AskUserQuestion, multiSelect: true)

One option per issue. Label: `#<number> <title>`. Description: issue url.

Nothing picked? Stop.

## 3. Fork agent per pick

For each picked issue:

```
Skill(skill: "fork-agent", args: "issue #<number>: <title> — <url>")
```

All picks independent — call Skill for each in the same message.

Done. No extra report beyond what fork-agent skill gives.
