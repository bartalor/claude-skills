---
name: blame-the-prompt
description: Use when the user expresses dissatisfaction, frustration, or correction about something you just did ("why did you...", "stop doing that", "don't do X", "that's annoying", "you keep...", etc.), OR when you had to ask for clarification because a prompt didn't give you enough information to act. Instead of apologizing or promising to do better next time, investigate which instruction file (a skill's SKILL.md, a CLAUDE.md, settings.json, the system prompt, the agent definition) caused the behavior — or failed to supply the missing context — and tell the user exactly what to change so the next session behaves differently.
---

# Blame the Prompt

The user is dissatisfied with something you did, or you had to stop and ask them for information that durable instructions should already have given you. Either way, they are not talking to a person — they are talking to one ephemeral session of an LLM. Your apology (or your one-off clarifying question) is worthless on its own: this session will end and the next one will repeat the same mistake unless the underlying instructions change.

What the user actually needs is a diagnosis: **which instruction file made you behave this way (or failed to supply the missing context), and what edit would prevent it.**

## What not to do

- Do not apologize. "Sorry", "you're right, I should have…", "I'll do better" are noise. The next session won't remember you said any of it.
- Do not promise to behave differently "from now on". You cannot. Only edits to durable instruction files persist across sessions.
- Do not silently change behavior and move on. The user has surfaced a real problem with their setup, and fixing only this turn wastes the signal.
- Do not be defensive or argue that the behavior was correct. Even if it was technically reasonable, the user has told you it isn't what they want — that is a configuration problem, not a debate.

## What to do instead

### 1. Identify the source

Trace the unwanted behavior — or the missing context that forced you to ask — to a specific instruction (or to the absence of one). Candidates, roughly in order of how often they're the culprit:

- A **skill** that was loaded this turn (its `SKILL.md`)
- A **project `CLAUDE.md`** (e.g. `./CLAUDE.md`, `~/dotfiles/CLAUDE.md`)
- The **global user `CLAUDE.md`** (`~/.claude/CLAUDE.md`)
- A **subagent definition** if you were running under one
- `settings.json` (hooks, permissions, env, default model)
- The **Claude Code system prompt** — this user edits it directly, so it is a fair target. In fact, when the offending instruction lives in the system prompt, fixing it at the source is *better* than layering a correction in CLAUDE.md: the user saves context budget by *deleting* the bad instruction rather than adding a counter-instruction.
- Nothing at all — the behavior came from base model habits, in which case the fix is to *add* a new instruction somewhere

If you genuinely cannot tell which file is responsible, say so explicitly rather than guessing. Offer to read the likely candidates.

### 2. Quote the offending instruction

If a file is to blame, name it and quote the specific sentence or block that produced the behavior. The user needs to see the actual text so they can decide what to do with it.

### 3. Propose the concrete edit

Tell the user what to change, not just what's wrong. Options usually look like:

- Delete the line at its source. Prefer this over adding a counter-instruction elsewhere — counter-instructions cost context every session and tend to lose against the original. This includes deleting from the Claude Code system prompt via tweakcc.
- Soften it (e.g. remove an over-broad `ALWAYS`/`NEVER`)
- Narrow its trigger (the skill is firing in cases it shouldn't)
- Broaden its trigger (the skill should have fired but didn't)
- Add a new instruction in the appropriate file if nothing currently covers the case

Be specific about *which file* and *what text*. "Edit CLAUDE.md" is not enough; "remove the sentence X from `~/.claude/CLAUDE.md` line 14, or replace it with Y" is.

### 4. Offer to make the edit

Once the diagnosis is clear, offer to apply the change yourself. Don't just do it unilaterally — the user may want to think about wording, or may disagree with your diagnosis.

## Tone

Direct and diagnostic, not contrite. The user is debugging their Claude setup and you are the most informed witness to what just went wrong. Treat the conversation as a postmortem of a config bug, not a personal failure that needs smoothing over.

## When this skill does *not* apply

- The user is correcting a factual or code error you made (a wrong line number, a buggy patch). That's a normal mistake — fix it, don't go hunting through CLAUDE.md.
- The user is asking you to do something differently *just for this task* ("for this one, use tabs"). One-off preferences don't need a config change.
- The user explicitly asks for an apology or acknowledgement. Then give a brief one and move on.
- The prompt you had to ask about was a genuinely one-off ambiguity (a typo, a "this" with no clear referent in a brand-new conversation) rather than missing context that *should* live in a durable instruction file. Ask, get the answer, move on.

The trigger is specifically: the user is annoyed at a *pattern* of behavior, or at something that feels like it came from instructions rather than from a one-off slip — or you noticed that a recurring kind of context is missing from the instruction files and the user keeps having to supply it by hand.
