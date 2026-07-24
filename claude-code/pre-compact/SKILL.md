---
name: pre-compact
description: Use right before running /compact when the session contains hard-won technical findings that regular compaction would lose. Curates and writes those findings to ~/.cache/claude/technical-context.md so the post-compact skill can inject them into the next session.
---

Compaction is about to run. Everything you know that isn't in the chat log will be gone. Regular compact keeps the narrative and user preferences fine — it loses the technical stuff that took real work to figure out.

**Scope — this file is technical only.** Facts about the codebase, the bug, the tools, the environment, the wrong turns you took getting there. Nothing else. User preferences, communication style, how they like to work, tone corrections — those don't belong here. If you catch yourself writing "user prefers X" or "user's style is Y", stop — wrong file.

Ask yourself, honestly: did you learn something *technical* this session that you'd be pissed to have to rediscover in the next one? Something that took a real investigation, a wrong turn, a doc dive, a debugger session? A fact about this codebase or system that isn't obvious from just reading the file?

If yes — write ONLY those things to `~/.cache/claude/technical-context.md`. Write it for your future self who will read it cold in one minute. Every dumb obvious fact you put in there is noise that will bury the one line that actually matters.

If no — don't create the file, and tell the user nothing was worth saving. An empty or padded file is worse than none.

No taxonomy, no headings-because-headings, no "in this session we…". Just the facts you'd want handed to you.

After writing (or deciding not to), tell the user in one line what happened so they know whether to expect an injection next session.
