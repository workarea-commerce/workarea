# WA-PROC-002 — Gate Label Hygiene

**Purpose:** Keep `gate:build-passed` / `gate:build-failed` labels accurate
relative to actual GitHub Checks status. Run this procedure whenever a label
looks stale or after CI automation is known to have misfired.

---

## Background

Three labels track CI gate status on every PR:

| Label | Meaning |
|---|---|
| `gate:build-pending` | Checks are still running (or haven't started yet) |
| `gate:build-passed` | All required checks completed with `SUCCESS` |
| `gate:build-failed` | One or more required checks completed with `FAILURE` |

The dispatcher bot sets these automatically, but labels occasionally drift out
of sync — e.g. a re-run succeeds after the label was set to `gate:build-failed`,
or a PR sits in `gate:build-pending` long after checks finished.

---

## Quick Reference: Label IDs

| Label | ID |
|---|---|
| `gate:build-pending` | `LA_kwDODCMvuc8AAAACY3y9vw` |
| `gate:build-passed` | `LA_kwDODCMvuc8AAAACY3y90A` |
| `gate:build-failed` | `LA_kwDODCMvuc8AAAACY3y95g` |

---

## Step-by-Step Procedure

### 1. Check the current checks status

```sh
PR=<number>
gh pr view "$PR" --json statusCheckRollup \
  --jq '[.statusCheckRollup[] | {name, status, conclusion}]'
```

Look at `status` and `conclusion`:

- Any `"status": "IN_PROGRESS"` or `"status": "QUEUED"` → build is **pending**
- All `"status": "COMPLETED"` and all `"conclusion": "SUCCESS"` → build **passed**
- Any `"status": "COMPLETED"` and `"conclusion": "FAILURE"` → build **failed**

One-liner summaries:

```sh
# Are any checks still running?
gh pr view "$PR" --json statusCheckRollup \
  --jq '[.statusCheckRollup[] | select(.status != "COMPLETED")] | length'
# 0 = all done; >0 = still running

# Did any completed check fail?
gh pr view "$PR" --json statusCheckRollup \
  --jq '[.statusCheckRollup[] | select(.conclusion == "FAILURE")] | length'
# 0 = no failures; >0 = at least one failure
```

### 2. Check the current gate label

```sh
gh pr view "$PR" --json labels \
  --jq '[.labels[].name | select(startswith("gate:"))]'
```

### 3. Apply the correct label

Replace whichever `gate:*` label is wrong with the accurate one. The pattern
is: remove the stale label, add the correct one.

**Build passed (all checks green):**

```sh
gh pr edit "$PR" --remove-label "gate:build-pending" \
                 --remove-label "gate:build-failed"
gh pr edit "$PR" --add-label "gate:build-passed"
```

**Build failed (any check red):**

```sh
gh pr edit "$PR" --remove-label "gate:build-pending" \
                 --remove-label "gate:build-passed"
gh pr edit "$PR" --add-label "gate:build-failed"
```

**Build still running:**

```sh
gh pr edit "$PR" --remove-label "gate:build-passed" \
                 --remove-label "gate:build-failed"
gh pr edit "$PR" --add-label "gate:build-pending"
```

> **Note:** `gh pr edit` silently ignores `--remove-label` for labels that are
> not currently set, so these commands are safe to run even if one of the labels
> is already absent.

---

## Docs-Only / Checks-Skipped PRs

Some PRs (documentation, config tweaks) intentionally skip certain CI jobs.
In this case checks may complete quickly with `"conclusion": "SKIPPED"`.

Treat `SKIPPED` the same as `SUCCESS` when deciding on labels — a skipped
check is not a failure. The one-liner filters above already handle this because
they only count `FAILURE` conclusions.

If a PR has **no checks at all** (empty `statusCheckRollup`), leave the label
as `gate:build-pending` and add a comment explaining that CI was not triggered.
Do not apply `gate:build-passed` without evidence that checks ran.

---

## Batch Audit: Find All Mismatched PRs

Run this to list open PRs whose gate label does not match their actual checks
state (useful before a release cut):

```sh
#!/usr/bin/env bash
# Audit gate label accuracy for all open PRs targeting `next`
set -euo pipefail

gh pr list --base next --state open --limit 100 \
  --json number,title,labels,statusCheckRollup |
jq -r '
  .[] |
  . as $pr |
  (
    # Determine actual state
    if (.statusCheckRollup | length) == 0 then "no-checks"
    elif (.statusCheckRollup[] | select(.status != "COMPLETED")) then "pending"
    elif (.statusCheckRollup[] | select(.conclusion == "FAILURE")) then "failed"
    else "passed"
    end
  ) as $actual |
  (
    [.labels[].name | select(startswith("gate:"))] | first // "none"
  ) as $label |
  select(
    ($actual == "pending"  and $label != "gate:build-pending")  or
    ($actual == "passed"   and $label != "gate:build-passed")   or
    ($actual == "failed"   and $label != "gate:build-failed")   or
    ($actual == "no-checks" and ($label | test("passed|failed")))
  ) |
  "#\(.number) | actual=\($actual) | label=\($label) | \(.title)"
'
```

---

## Verification Example

> **Applies the procedure to a real PR with a known mismatch.**

PR #1004 ("ci: Add bundler-audit dependency scanning on PRs") had
`gate:build-pending` even after all 36 CI checks completed with `SUCCESS`.

**Verify the mismatch:**

```sh
PR=1004

# Confirm all checks are done and passing
gh pr view "$PR" --json statusCheckRollup \
  --jq '[.statusCheckRollup[] | select(.status != "COMPLETED")] | length'
# Expected: 0

gh pr view "$PR" --json statusCheckRollup \
  --jq '[.statusCheckRollup[] | select(.conclusion == "FAILURE")] | length'
# Expected: 0

# Confirm stale label
gh pr view "$PR" --json labels --jq '[.labels[].name | select(startswith("gate:"))]'
# Expected: ["gate:build-pending"]
```

**Fix the label:**

```sh
gh pr edit "$PR" --remove-label "gate:build-pending"
gh pr edit "$PR" --add-label "gate:build-passed"
```

**Confirm correction:**

```sh
gh pr view "$PR" --json labels --jq '[.labels[].name | select(startswith("gate:"))]'
# Expected: ["gate:build-passed"]
```

---

## Related

- `docs/sdlc-project-board.md` — status label ↔ project board column mapping
- `.github/workflows/` — CI workflows whose check names appear in `statusCheckRollup`
- Issue [#878](https://github.com/workarea-commerce/workarea/issues/878) — tracks label hygiene drift
