---
name: edit-claude-instructions
description: Invoke When editing a Claude Code instruction file (SKILL.md, CLAUDE.md, AGENTS.md, or similar).
---

# Edit Claude Instructions

When you edit a Claude Code instruction file (SKILL.md, CLAUDE.md, AGENTS.md, etc.), your responsibility is to the document as a whole, not just to the diff.

Before saving the edit:

1. Re-read the whole file with the addition in place.
2. **Contradictions** — does the new content conflict with anything already there?
3. **Duplication** — is this point already made elsewhere, maybe in different words?
4. **Placement** — does the addition belong merged into an existing section, or warrant its own?
5. **Staleness** — does the addition make any existing guidance less relevant or redundant?

Decide what fits best on your own — don't pepper the user with questions. Then concisely tell them what you changed beyond the literal addition (merged X into Y, removed now-stale Z, etc.) and let them approve.
