# Deprecation Sweep Results

**Branch:** `wa-verify-001-deprecation-sweep`
**Base:** `next`
**Last updated:** 2026-03-17 (issue #910 refresh)

## Symptom

Deprecation warnings emitted by Rails, Ruby, or third-party gems during test runs indicate
API usage that will break in future versions. Left unaddressed, these warnings become
errors, causing test failures or runtime crashes after version upgrades.

## Root cause

Workarea was developed against Rails 6.1 APIs. As Rails 7.x introduced new defaults and
removed deprecated patterns (e.g., `ActiveSupport::Deprecation.new`, `update_attributes`,
BSON Symbol), existing code may emit `DEPRECATION WARNING` lines in test output.

## Detection

Run the test suite with deprecation warnings enabled:

```bash
RUBYOPT="-W:deprecated" WORKAREA_SKIP_SYSTEM_TESTS=true bundle exec rake test 2>&1 | grep "DEPRECATION WARNING"
```

System tests are skipped (`WORKAREA_SKIP_SYSTEM_TESTS=true`) to avoid chromedriver
timeout issues; unit and integration tests execute cleanly.

## Fix

Address each deprecation category as it appears. Known fixed categories are listed in
[Known Deprecation Categories Addressed](#known-deprecation-categories-addressed) below.
Open follow-up issues for any new deprecations discovered in higher Rails version appraisals.

---

## Sweep Findings

**Zero** `DEPRECATION WARNING` lines were found in the output across `core`,
`admin`, and `storefront` engines at the time of the initial sweep
([WA-VERIFY-001, issue #762](https://github.com/workarea-commerce/workarea/issues/762) — closed/done).

## Action Items from Initial Sweep

| Item | Status |
|------|--------|
| Test suite run with deprecation warnings captured | ✅ Done |
| All DEPRECATION WARNING lines reviewed and categorized (None found) | ✅ Done |
| Workarea-owned deprecations fixed (None found) | ✅ Done |
| Third-party deprecations documented (None found) | ✅ Done |

**Client Impact:** None expected.

---

## Follow-up Deprecation Audits

The initial sweep was against the default (`rails61`) appraisal. Follow-up
issues track deprecation audits at higher Rails versions:

### Rails 7.0 Appraisal Baseline

**[WA-VERIFY-071, issue #1043](https://github.com/workarea-commerce/workarea/issues/1043)** — *Open (In Progress)*

Captures the Rails 7.0 appraisal deprecation warning count as a baseline —
to measure progress when we upgrade and to catch regressions before promoting
Rails 7.0 to default. Companion to WA-VERIFY-001 (Rails 6.1 sweep) and
WA-VERIFY-012 (Rails 7.1+ audit).

### Rails 7.1+ Deprecation Warnings Audit

**[WA-VERIFY-012, issue #819](https://github.com/workarea-commerce/workarea/issues/819)** — *Open (Blocked: dependency)*

Run a representative test run under the Rails 7.1 appraisal with deprecation
warnings enabled, capture output, and triage. Blocked on Rails 7.1 appraisal
stability (boot / test-suite CI passing).

### Rails 7.2 Deprecation Sweep

**[WA-VERIFY-007, issue #793](https://github.com/workarea-commerce/workarea/issues/793)** — *Open (Blocked: dependency)*

Focused sweep under the Rails 7.2 appraisal to identify warnings that could
become errors in future Rails versions. Blocked on Rails 7.2 appraisal CI
stabilisation.

---

## Known Deprecation Categories Addressed

These categories were identified during research or earlier sweeps and have
dedicated follow-up issues or are already resolved:

### `ActiveSupport::Deprecation.new` (Rails 7.1 API change)

**[WA-RAILS7-008, issue #700](https://github.com/workarea-commerce/workarea/issues/700)** — *Closed (Done)*

In Rails 7.1, the global `ActiveSupport::Deprecation` instance was removed
and per-gem deprecators are preferred. Workarea creates its own deprecation
instance in `core/lib/workarea.rb`. Issue #700 tracks the fix to use
`Rails.application.deprecators[:workarea]` on Rails 7.1+ while staying
compatible with Rails 6.1/7.0.

### `update_attributes` / `update_attributes!` (Mongoid deprecation)

- **[WA-NEW-009, issue #626](https://github.com/workarea-commerce/workarea/issues/626)** — *Closed (Done)* — production code
- **[WA-NEW-015, issue #659](https://github.com/workarea-commerce/workarea/issues/659)** — *Closed (Done)* — admin/storefront controllers

`update_attributes` was deprecated and removed in Mongoid 8. Both production
models and controller layers were updated to `update` / `update!`.

### BSON Symbol deprecation

**[WA-NEW-010, issue #627](https://github.com/workarea-commerce/workarea/issues/627)** — *Closed (Done)*

BSON Symbol serialization was deprecated in the Mongoid/BSON stack. Issue
#627 eliminated the warning from the test suite.

### Mongoid 8.x upgrade (prerequisite for Rails 7 support)

**[WA-RAILS7-004, issue #690](https://github.com/workarea-commerce/workarea/issues/690)** — *Open*

Mongoid 8 is a prerequisite for full Rails 7 support and removes several
deprecated patterns. Tracked separately as a larger upgrade effort.

### ActiveJob queue adapter compatibility

**[WA-RAILS7-024, issue #755](https://github.com/workarea-commerce/workarea/issues/755)** — *Closed (Done)*

Rails 7 changed how queue adapters are configured; this issue addressed
compatibility.

### ActiveModel::Errors API (Rails 6.1+)

**[WA-NEW-008, issue #625](https://github.com/workarea-commerce/workarea/issues/625)** — *Closed (Done)*

Rails 6.1 introduced a new `ActiveModel::Errors` API; the old hash-style
access was deprecated. `PasswordReset` error-copying was updated.

### Zeitwerk autoloading

No standalone deprecation warning was emitted during the sweep. Zeitwerk
compatibility is tracked broadly by
**[WA-VERIFY-058, issue #1023](https://github.com/workarea-commerce/workarea/issues/1023)**
(closed/done) — a repo-root Zeitwerk check script was added so constant
loading failures surface early in CI.

---

## Categories With No Follow-up Issue (and Why)

| Category | Reason no issue needed |
|----------|------------------------|
| Third-party gem deprecations (non-Workarea) | Zero found during sweep. If discovered in future sweeps, issues will be opened then. |
| Rails core deprecations in core/admin/storefront | Zero found during sweep (confirmed in WA-VERIFY-001). |
| System test deprecation warnings | System tests were intentionally skipped due to chromedriver timeout issues; this is the accepted scope for this sweep. |

---

## References / Links

- [WA-VERIFY-001, issue #762](https://github.com/workarea-commerce/workarea/issues/762) — Initial deprecation sweep (closed)
- [WA-VERIFY-071, issue #1043](https://github.com/workarea-commerce/workarea/issues/1043) — Rails 7.0 baseline
- [WA-VERIFY-012, issue #819](https://github.com/workarea-commerce/workarea/issues/819) — Rails 7.1+ audit
- [WA-VERIFY-007, issue #793](https://github.com/workarea-commerce/workarea/issues/793) — Rails 7.2 sweep
- [Ruby `-W:deprecated` flag docs](https://www.ruby-lang.org/en/documentation/)
