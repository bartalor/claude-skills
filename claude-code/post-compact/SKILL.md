---
name: post-compact
description: Use right after /compact if the pre-compact skill was run in the prior session. Reads ~/.cache/claude/technical-context.md into context and deletes it so it can't leak into unrelated future sessions.
---

1. Issue a Read tool call for `~/.cache/claude/technical-context.md` in THIS turn. Do this even if the file's contents appear in a system-reminder from a prior session — a system-reminder is not a Read tool call in this turn, and step 3 is forbidden without one. If the file doesn't exist or is empty, say so in one line and stop.
2. Absorb its contents as authoritative technical context for this session.
3. Only after step 1's Read tool call succeeded in THIS turn, delete the file: `rm -f ~/.cache/claude/technical-context.md`.

Do not summarize the file back to the user unless they ask. Just confirm in one line that context was loaded (or that there was none), and proceed.
