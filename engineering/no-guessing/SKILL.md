---
name: no-guessing
description: Use BEFORE taking any non-trivial action (edit, command, refactor, fix, design decision). Forbids proceeding with unverified assumptions or guesses. Requires surfacing every assumption to the user, verifying them, then reconciling the plan with reality — and offering to preserve the hard-won knowledge for next time.
---

Before you act, you must be **100% certain** of everything the action depends on. If you're not, you do not proceed. Guessing is forbidden. "Probably", "I think", "likely", "should be" — none of those clear the bar.

## 1. Surface every assumption

Before doing the thing, list every unverified assumption you're relying on. Be exhaustive and specific — not vibes, not a summary. Each item should be a concrete factual claim that could be checked (a function signature, a file's contents, an API's behavior, a config value, a data shape, a tool's default, an invariant of the codebase, etc.).

Format:

> **Unverified assumptions before I proceed:**
> 1. `<claim>` — how I'd verify: `<command / file to read / doc to fetch>`
> 2. …

Then **stop and wait for the user.** Do not start verifying yet. The user decides whether to verify them one at a time or all at once.

## 2. Verify — then reconcile

After verifying (however the user directs), report back with a clean summary:

- **Verified:** the assumptions that held.
- **Disproven:** the assumptions that were wrong, with the actual truth.
- **Impact on the plan:** for **each** disproven assumption, explicitly trace what it changes in the plan. Not a lumped paragraph — one bullet per disproven assumption, naming the assumption and then the concrete consequence (which step drops, which changes to what, which new step appears). If several assumptions collapse into the same consequence, say that. If the whole approach is now wrong because of a specific disproven assumption, name that assumption and say so plainly.

Only after this reconciliation do you propose the (possibly new) plan and wait for the go-ahead.

## 3. Preserve the discoveries

This research was expensive; without saving it, the next session pays the same cost. Offer to save what was learned — but do it well:

- **Ask where** — don't pick unilaterally. Propose a location that fits the scope (this function / module / repo / cross-project): an existing `CLAUDE.md`, a subsystem notes file, `docs/`, etc.
- **Split across destinations.** Different findings from the same session may belong in different places (one new bullet in a module notes file, one one-line tweak to a top-level `CLAUDE.md`, one not worth saving). Propose each placement separately.
- **Curate, don't dump.** Save the durable facts — the corrected mental model, the gotcha, the actual signature/behavior/invariant — not the journey, not the disproven assumptions. When tweaking an existing file, integrate in its own voice; never reference the research session ("from finding #4", "as we discovered") — the reader has no context for that. Keep it terse and indexable: heading, fact, and a source pointer (file:line, doc URL) if useful.

If the user declines to save it, drop it. Don't nag.

## The anti-pattern this skill exists to kill

> "I'll just try it and see" → wrong assumption bakes into the edit → bug → fix → different wrong assumption → bug → …

and its sibling:

> spend an hour learning how something actually works → fix the thing → close the session → next week, relearn the same hour.
