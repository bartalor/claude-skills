---
name: git-preserve-history-on-move
description: When moving or renaming a file tracked in git, preserve history across the rename before committing. Use on any `mv`/rename of a tracked file.
---

Git detects renames by content similarity. Mixing a move with edits in one commit can break `git log --follow` and `git blame` across the rename.

- Use `git mv`.
- Move-only commit; edit in a follow-up.
- Before committing, verify rename detection: `git diff --cached --stat -M` should show `old => new` (a rename), not separate delete + add. If not, split the commit.
