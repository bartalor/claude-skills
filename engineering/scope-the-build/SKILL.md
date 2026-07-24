---
name: scope-the-build
description: Use when verifying a fix with an expensive build/test step. Start at the cheapest check that could disprove the fix; climb only when it passes.
disable-model-invocation: true
---

**Robustness is not the same as being stupid about build iterations.**
Robustness means following best practices and knowing exactly what
you're doing and why. It has *nothing* to do with burning time on
redundant, out-of-scope builds. Wasting iterations on checks that
can't tell you anything new isn't rigor — it's the opposite: it's not
knowing what you're doing. This is the central point of this skill.
Scoped, deliberate iteration *is* the rigorous approach.

From there, the cost of verifying a change should match what's being
verified. A two-line fix to a parser does not justify a 40-minute full
build as the *first* signal. If the previous attempt didn't even
survive a 2-second syntax check, the next attempt's first question is
"does it survive that 2-second check?" — not "did the whole pipeline
turn green?"

Every check you skip must be skipped on purpose, with a reason. Every
check you run must earn its cost.

## The ladder

Pick the lowest rung that could falsify the fix. Climb only after it
passes. Roughly:

1. Re-read the diff.
2. Static check (parse, type-check, lint).
3. Narrow build — only what was touched.
4. Narrow test — the specific test exercising the changed path.
5. Full build / full suite.
6. Integration / end-to-end.

If the previous failure was at rung N, the next attempt's first check
is rung N — not rung N+3.

## Be orderly about it

Prefer an organized, layered build setup — the rungs above expressed
as actual written-down things in the project, wherever they fit: a
script, a build file, a config file, or some combination — over ad-hoc
invocations. If the same build or test keeps coming up with slight
variations, write it down as persistent build logic instead of
re-running it from memory. Don't force structure where it doesn't fit,
but when it does, lean toward order.

## The rule

Before running a verification step, say — to yourself, out loud in the
response — which rung it is and why that rung is the right one for this
change. If the answer is "I didn't think about it, I just ran the
usual," go back and think about it.
