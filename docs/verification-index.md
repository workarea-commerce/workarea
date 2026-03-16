# Verification Index — WA-DOC-007

This index lists all developer verification scripts and runbooks in the
`scripts/` directory, along with their corresponding documentation in
`docs/verification/`.  Run any of these before pushing to catch issues early.

---

## Quick-run Scripts

| Script | Purpose | Ruby | Issue |
|--------|---------|------|-------|
| [`scripts/run-benchmarks.sh`](../scripts/run-benchmarks.sh) | Reproduce test-suite performance baseline | 3.2.7 | #728 |
| [`scripts/verify-zeitwerk.sh`](../scripts/verify-zeitwerk.sh) | Verify Zeitwerk autoloading across all engines | 2.7.8 | #1023 |

---

## Verification Runbooks

### `wa-verify-003` — Load Defaults Audit
**File:** [`docs/verification/wa-verify-003-load-defaults-audit.md`](verification/wa-verify-003-load-defaults-audit.md)  
Audit of `config.load_defaults` behavioral flags for Rails 7.0 / 7.1 compatibility.

---

### `wa-verify-004` — Performance Baseline
**File:** [`docs/verification/wa-verify-004-perf-baseline.md`](verification/wa-verify-004-perf-baseline.md)  
Baseline measurements for test-suite performance. See also [`scripts/run-benchmarks.sh`](../scripts/run-benchmarks.sh).

---

### `wa-verify-031` — Default-Appraisal Deprecation Warning Snapshot
**File:** [`docs/verification/wa-verify-031-default-appraisal-deprecations.md`](verification/wa-verify-031-default-appraisal-deprecations.md)  
Captures `DEPRECATION WARNING:` lines emitted during boot. Commit-diffable artifact.

---

### `wa-verify-058` — Zeitwerk Autoload Check  ← **new**
**Script:** [`scripts/verify-zeitwerk.sh`](../scripts/verify-zeitwerk.sh)  
**Runbook:** [`docs/verification/wa-verify-058-zeitwerk-check.md`](verification/wa-verify-058-zeitwerk-check.md)  
**Issue:** [#1023](https://github.com/workarea-commerce/workarea/issues/1023)

Runs `zeitwerk:check` against each engine's dummy app to confirm Zeitwerk
autoloading is healthy.  Run this before pushing any commit that adds, removes,
or renames files under `app/` or modifies `autoload_paths`.

```sh
# Check all engines (recommended pre-push)
./scripts/verify-zeitwerk.sh

# Check a single engine
./scripts/verify-zeitwerk.sh core
./scripts/verify-zeitwerk.sh admin
./scripts/verify-zeitwerk.sh storefront
```

Requirements: Ruby 2.7.8 via rbenv, MongoDB running, `bundle install` done.

See also: [`docs/rails7-migration-patterns/zeitwerk-notes.md`](rails7-migration-patterns/zeitwerk-notes.md)

---

## CI Gate

All of the above checks are subsumed by the full CI gate documented in
[`docs/verification/wa-ci-008-local-build-gate.md`](verification/wa-ci-008-local-build-gate.md).
Use the individual scripts for faster feedback during development.
