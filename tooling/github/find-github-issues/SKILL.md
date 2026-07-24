---
name: find-github-issues
disable-model-invocation: true
description: Find good open-source GitHub issues to work on in a given repository. Use whenever the user asks for issues to work on, wants to contribute to an open-source project, asks "what should I pick up in repo X", or wants a triage of open issues in a repo to find one worth tackling. Use this skill even if they don't say the word "skill" — any request to surface workable issues in a GitHub repo should trigger it.
---

# Find GitHub Issues To Work On

Surface issues from a GitHub repository that a contributor could realistically pick up and finish. Final judgment is manual, but do the cheap objective rejects in bulk first so tokens are only spent reading plausible candidates.

## Skipped-issues log

Running record of issues already triaged and rejected, so the same dead ends aren't re-investigated. Machine-parseable so the prefilter can drop skipped issues automatically.

- **Location**: `.skipped-issues.yaml` at the repo root, on the **personal branch** (see `open-source-workflow`). Never push upstream.
- **Format**: YAML list of `{number, reason}`:
  ```yaml
  - number: 1234
    reason: working-as-designed per maintainer
  - number: 1235
    reason: scope too large
  ```
- **When rejecting an issue**: append an entry with `Edit`. Keep `reason` to one line. Do **not** `Read` the file first — the skip list is already applied by `bin/filter`, so no issue you're triaging can already be logged. Use any known-unique anchor from context (e.g. the last entry from an earlier append this session, or a static footer if you add one); `Edit` enforces uniqueness itself.

## Workflow

### 1. Search by binary-search on filters, not by scanning

Searching for a workable issue is **binary search over filters**, not linear scanning. A human on GitHub doesn't read issue 1, then issue 2, then issue 3 — they crank filters up until the survivor set is small and dense with plausible hits.

The principle: **start restrictive.** Cast a narrow net first — heavy filters that disqualify most issues — so whatever survives is high-signal. Loosen only if the set comes back empty.

The loop:

1. Run a restrictive filter.
2. Look at what survived — as a set.
    - **Empty?** One filter was too strict. Relax the least confident one, re-run.
    - **Non-empty but noisy** (spammy authors, wrong labels, wrong `updated_at` band, hardware-gated, etc.)? Form one hypothesis about what's cluttering, tighten, re-run.
    - **Non-empty and dense with plausible hits?** Stop tightening. Move on to reading bodies.
3. Only start reading issue bodies once step 2 lands on "dense with plausible hits". Reading bodies while the set is still noisy is the linear-scan trap.

#### How to do the loop fast

Cache the raw GraphQL once per session, then run cheap `jq` passes over the cache while iterating.

Run from the repo's working directory (so `bin/filter` picks up `.skipped-issues.yaml` if it's there):

```bash
# Cache the raw GraphQL once per session (or when you want fresh data):
gh api graphql \
  -F owner=<owner> -F repo=<repo> \
  -f query="$(cat "$CLAUDE_PLUGIN_ROOT/skills/find-github-issues/candidates.graphql")" \
  > /tmp/<repo>-issues.json

# Then iterate: pipe the cache through a per-run jq transform, into the skill's filter.
# Example: drop issues created in the last 14 days.
jq '.data.repository.issues.nodes |= map(select(.createdAt < (now - 14*86400 | todate)))' \
    /tmp/<repo>-issues.json \
  | "$CLAUDE_PLUGIN_ROOT/skills/find-github-issues/bin/filter"
```

`bin/filter` reads `.skipped-issues.yaml`, extracts the numbers, and hands them to `filter.jq` as the exclusion set.

`filter.jq` is the **baseline** — universal rejects that apply to every repo. It currently drops:

- assigned issues,
- issues with an open linked PR,
- issues with a closed-unmerged linked PR updated in the last 30 days,
- issues labelled `blocked`, `wontfix`, `duplicate`, `invalid`.

**Per-run tuning goes in the inline `jq` upstream of `bin/filter`, not in `filter.jq`.** Session criteria change every time — min age, label preferences, author blocklists, comment counts — and typing the criterion inline is fast because the cache is on disk. Only edit `filter.jq` when a rule is genuinely universal.

Hypotheses worth considering when you look at a noisy survivor set:

- **Age**: issues younger than 7–14 days on AI-spam-heavy repos attract low-quality PRs within hours — drop them.
- **Labels**: what does this repo actually use? `gh label list -R <owner>/<repo>`. Some repos have `status: blocked` instead of `blocked`, some use `help wanted` as a positive signal, some use `needs-triage` ambiguously.
- **Linked-PR window**: is 30 days right? Fast-moving repo → shorter. Slow one → longer.
- **Sort**: `orderBy` in the GraphQL defaults to `UPDATED_AT DESC`. If today's activity dominates, try `CREATED_AT ASC` (find aged-but-unresolved issues) or paginate with `endCursor`.
- **Author / assignee patterns**: spammy authors filing report-only issues, or issues perpetually assigned to a bot.

**Never filter *for* `good first issue`.** These are the most swarmed issues on any repo (bots and AI-agent accounts race each other on them within hours) and they skew mechanical/trivial, which conflicts with the "no busywork" rule. Ignore the label entirely — do not include it as a positive signal.


### 2. Read the survivors and judge

For each surviving candidate you're seriously considering:

**a) The issue itself.** Read body and every comment. Note who's engaged, what maintainers said, whether scope is clear.

**b) Linked PRs.** The GraphQL blob already lists them with state, author, updatedAt. If any look relevant, `gh pr view <n> --comments` to see **why** it closed. A "no time, abandoning" from months ago means the issue is wide open; a recent "let's go a different direction" from a maintainer means proceed with caution.

**c) Rarely: full timeline.** `gh api repos/<owner>/<repo>/issues/<n>/timeline --paginate` catches the specific case where an assignee is mid-implementation on a branch without a PR yet. Only fetch this if you suspect that's happening — it's the one signal the GraphQL query doesn't already surface.

### 3. Output

Return a single issue: the one that fits best. Include the link and why it was picked.
