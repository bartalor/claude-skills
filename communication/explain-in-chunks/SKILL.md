---
name: explain-in-chunks
disable-model-invocation: true
description: Use when the user asks for an explanation "in chunks", "one at a time", "in smaller pieces", "bit by bit", or otherwise signals that a full answer would be too much to absorb at once.
---

# Explain In Chunks

The user wants the explanation delivered one small piece per turn, so they can absorb each one before the next arrives. They drive the pace by asking for the next piece.

### Subject of the skill

When the skill is invoked, assume it refers to **your previous message** — the user is asking you to re-deliver that same content in chunks, not to explain something new. Only treat it as a new topic if the user explicitly names one.

> ## ⚠️ CRITICAL: CHUNKING MEANS WORD-FOR-WORD PARTITION ⚠️
>
> **This is the #1 failure mode of this skill. Read it carefully.**
>
> The chunks you deliver, concatenated in order, must reproduce the source text **word for word, in order**. You are cutting the existing sentences into smaller pieces — not rewriting, not summarizing, not paraphrasing, not tightening, not dropping connectors ("that's why," "because," "so"), not dropping labels ("the power wall," "Dennard scaling"). Just insert cut points into the original text.
>
> This applies from the very first chunk, not only when slicing finer on re-invocation. The source text is your previous message (per "Subject of the skill" above).
>
> **Mandatory check before sending any chunk:** concatenate the chunks you've sent so far plus this one. Does the result match the source text word for word up to that point? If not, you changed content. Fix it before sending.

### Re-invocation means "slice finer"

If the skill is invoked a second time while you're already chunking, it means the chunk you just gave was still too big. Take **that same chunk** and break it into smaller sub-chunks, then deliver the first sub-chunk. Don't move on to the next planned chunk — go deeper into the current one. The word-for-word partition rule above applies to the sub-chunks just as it did to the chunks.

## Rules

### 1. One chunk per turn. Then stop.

A chunk is one idea — usually 1–3 sentences. Not "one section with three subsections". Not "the first half of the explanation". One thought, then silence, then wait for the user.

### 2. Do not preview the structure.

No "I'll break this into 5 parts: A, B, C, D, E. Starting with A:". That dumps the whole outline up front, which is exactly what the user asked you not to do. Just give the first chunk.

### 3. Do not end with "want me to continue?" every time.

They already asked for chunks — they know they can ask for more. A trailing prompt on every turn is noise. Just deliver the chunk and stop. (Once, at the very end of the first chunk, a brief "say 'next' when ready" is fine. After that, nothing.)

### 4. Let the user redirect.

They may respond with "next", "go on", "ok" — give the next chunk. They may also ask a follow-up about the current chunk ("wait, what does X mean?") — answer that, don't barrel ahead to the next planned chunk. Their question replaces the next chunk; resume the sequence only when they ask to.

### 5. No headers, no bullets, no bold inside a chunk.

Formatting turns a chunk back into a structured lesson. Plain prose. If the chunk is genuinely a list (e.g. "the three arguments are…"), that's a list — but that should be rare.

### 6. Stay in this mode until the explanation is done or the user changes topic.

Don't revert to full-blast answers mid-explanation. If the user asks a new, unrelated question, the skill no longer applies and you answer normally.

### 7. Announce when the explanation is finished.

When you deliver the final chunk, tell the user explicitly that it's the last one (e.g. "— and that's the end."). Otherwise they'll keep typing "next" not knowing they've already hit the bottom. Don't rely on the user to infer it from the content.

## Anti-patterns

- "Here's the first of 4 parts. **Part 1: Setup.** [3 paragraphs]" — that's not a chunk, that's a section.
- "Chunk 1: X is a thing. Chunk 2: It works by… Chunk 3: …" — all chunks in one turn defeats the purpose.
- Ending every chunk with "Ready for the next one?" — noise; they know how to ask.
- Previewing "we'll cover A, B, C, D" before chunk 1 — that's the dump they were avoiding.
