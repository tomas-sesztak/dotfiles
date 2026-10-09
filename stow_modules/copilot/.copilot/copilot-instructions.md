# Global Instructions

## Tooling & Workflows
- **Git:**
    - Never commit directly to `main` or `master`, always pull fresh main and create new branch
    - Never commit, push, or open PRs without explicit permission
- **Podman:**
    - Ask before running destructive commands: `podman … prune`, `podman rm`, `podman rmi`, `podman volume rm`, `podman network rm`
- **Safety:** Do not execute destructive file system operations (`rm -rf`, raw database drops) without explicit permission

## Code Style & Formatting
- Write concise, self-documenting code. Favor strong typing (TypeScript, type hints in Python)
- Comment only non-obvious "why" (e.g. complex domain logic), one line max; no docstrings for obvious code
- Avoid adding third-party dependencies for simple tasks that native/built-in libraries can handle
- **Refactoring:** Keep diffs small and targeted. Do not rewrite surrounding unchanged code unnecessarily

## Communication & Formatting
- **Tone:** Direct, concise, technical. Minimal conversational filler
- **Errors:** When iterating over a fix, ask user for directions after 3 tries, do not loop endlessly

## Project level instructions
- **Rules:** always respect rules stated in project-level AGENTS.md/CLAUDE.md/copilot-instructions.md
- **Precedence:** project-level rules override these global rules on conflict

## Decision-Making Protocol

Before implementing, STOP and ask when:
- Choosing between multiple valid architectural approaches
- Introducing a new dependency/library
- Deciding on data models, API shapes, or file/folder structure
- Uncertain about requirements or trade-offs
- A choice would be costly to reverse later

When asking, present:
1. The decision point
2. 2-3 options with brief pros/cons
3. Your recommendation (if you have one)

Do NOT ask for:
- Naming variables/functions
- Formatting/style (follow existing conventions)
- Obvious bug fixes
- Anything with only one reasonable approach

**Autopilot/autonomous mode:** don't ask (this protocol and the 3-tries rule included). Make the call, state assumptions, and report blockers in the final summary. Explicit-permission rules (commit, push, destructive ops) still apply: skip those actions and report them.

