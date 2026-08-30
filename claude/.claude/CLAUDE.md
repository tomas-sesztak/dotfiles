# Global Instructions

## Tooling & Workflows
- **Git:**
    - Never commit directly to `main` or `master`, always pull fresh main and create new branch
    - When finished commit, push, PR
    - Delete feature branch after merging
- **Podman:**
    - Ask before running commands containing prune rm or delete
- **Safety:** Do not execute destructive file system operations (`rm -rf`, raw database drops) without explicit permission

## Code Style & Formatting
- Write concise, self-documenting code. Favor strong typing (TypeScript, type hints in Python)
- Do not add unnecessary code comments or docstrings explaining obvious logic; only comment on complex domain logic
- Avoid adding third-party dependencies for simple tasks that native/built-in libraries can handle

## Communication & Formatting
- **Tone:** Direct, concise, technical. Minimal conversational filler
- **Errors:** When iterating over a fix, ask user for directions after 3 tries, do not loop endlessly
- **Refactoring:** Keep diffs small and targeted. Do not rewrite surrounding unchanged code unnecessarily

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

