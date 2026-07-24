---
name: bidi-text
disable-model-invocation: true
description: How to correctly write and edit files containing mixed RTL (Hebrew/Arabic) and LTR (Latin/digits) text. Use this whenever writing, editing, or fixing a plain-text file (`.txt`, `.md`, email drafts, notes) that mixes Hebrew or Arabic with English words, numbers, punctuation, or code identifiers — especially when the user complains that rendering looks wrong, characters appear in the wrong order, or bidi/RTL is broken.
---

# Bidi text

## The core: this is manual, per-line work

Placing bidi marks correctly in a mixed-direction plain-text file is a manual, per-line task. You cannot script the judgment. For each mixed line you have to:

- Read it and decide the intended reading order word by word.
- Identify each neutral character (space, comma, period, colon, digits) that sits between a Hebrew run and a Latin run.
- Decide which side each neutral semantically belongs to.
- Place a mark or isolate exactly where the Unicode Bidi Algorithm would otherwise resolve against that intent.

No regex, no "add RLM everywhere Hebrew meets Latin" heuristic works. Any attempt to automate the judgment part produces wrong output — Latin runs land next to the wrong Hebrew word, neutrals bind to the wrong side, etc.

## What can be automated (safely)

Only content-independent, mechanical rules:

- Prepend U+200F (RLM) to any paragraph whose first strong character is Latin, when the document is Hebrew-dominant.
- Wrap URLs, code identifiers, or version strings in U+2066…U+2069 (LRI…PDI) so their internal order is isolated from surrounding context.
- Hard-wrap long lines at word boundaries so soft-wrap can't split a bidi run across visual lines.

These are safe because they don't depend on what the sentence means.

## What cannot be automated

- Deciding intended reading order of words in a mixed line.
- Deciding which side a neutral (comma, digit, space) semantically belongs to.
- Anything that requires reading the sentence to answer.

## Rendering is deterministic — use that

Given the bytes plus the paragraph direction, the Unicode Bidi Algorithm produces exactly one visual order. If a line renders "wrong," it's rendering exactly what the bytes say — the bytes just don't yet encode the intended order. Fix the bytes, not the viewer.

Do not walk the algorithm by hand — the rule interactions are subtle and easy to get wrong. Use `python-bidi` to compute the visual order and to test candidate mark placements before writing them to the file. Invoke it via `uv run --with python-bidi python3 -c '...'`. Never `pip install` it.

## The tools

- **U+200F RLM** — invisible strong-RTL. Use to force paragraph direction, bind a neutral to the Hebrew side, or split two Latin runs so an RTL paragraph places them individually (see below).
- **U+200E LRM** — invisible strong-LTR. Use to bind a neutral to a Latin run (e.g. keep a comma or digit stuck to the English word).
- **U+2066 LRI / U+2067 RLI / U+2068 FSI … U+2069 PDI** — isolates. Wrap a substring so its **internal** ordering is protected from the surrounding paragraph. They do NOT change where the wrapped chunk sits relative to surrounding runs — the paragraph still positions the whole isolate as a single unit at exactly the same spot it would have placed the underlying content. If two LTR runs are appearing in the wrong visual order inside an RTL paragraph, wrapping them together in one isolate will not fix it.

### Splitting two Latin runs in an RTL paragraph

Two Latin words separated only by a space in an RTL paragraph merge into one LTR block. The block's *rightmost* Latin character ends up adjacent to the Hebrew — usually the opposite of what you want. LRM in the space does not split them; the space is still an L-neutral bound by L on both sides. Put an **RLM immediately after the first Latin run** (before the space). That makes the space sit between an RTL mark and an L run, so it resolves RTL and the two Latin runs become independent units placed in RTL order by the paragraph.

Insert the real Unicode codepoints, not the escape text `\u200F`.

## Verification

- Dump bytes with `xxd` or `python3 -c "print(repr(open(p).read()))"` and confirm marks are only where you meant them.
- Check the file in the actual target viewer. Confirm word-by-word which Hebrew word each Latin run sits next to — don't declare it fixed from a glance.

## Anti-patterns (all committed in a real session)

- Wrapping every inline Latin run with RLM on both sides. Pushes the run out of its natural position.
- Reaching for LRI…PDI to fix the visual *position* of a run. Isolates fix internal order, not external position. If the wrong two words are ending up adjacent, an isolate around them won't move them.
- Typing the six literal characters `\u200F` into the file instead of inserting the U+200F byte.
- Editing the file before checking whether the problem is soft-wrap or a viewer setting.
- Calling it fixed from a screenshot without confirming which words are actually adjacent.

