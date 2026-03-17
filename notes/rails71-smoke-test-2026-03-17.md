# Rails 7.1 Appraisal Smoke Test — 2026-03-17

**Issue:** #1061 (WA-VERIFY-079)
**Branch:** issue-1061-rails71-smoke
**Ruby version:** 2.7.8 (rbenv)
**Date:** 2026-03-17

---

## Summary

The Rails 7.1 appraisal gemfile **cannot bundle** due to a Mongoid version incompatibility.
Neither a boot check nor a test run was possible.

**Colima status:** Not running (Docker services unavailable, would have blocked test runs anyway)

---

## Bundle Install Attempt

```sh
BUNDLE_GEMFILE=gemfiles/rails_7_1.gemfile bundle install
```

### Error Output

```
Fetching https://github.com/workarea-commerce/rails-decorators.git
Fetching gem metadata from https://rubygems.org/........
Resolving dependencies...
Could not find compatible versions

Because every version of workarea-core depends on mongoid ~> 7.4
  and mongoid >= 7.3.4, < 8.0.7 depends on activemodel >= 5.1, < 7.1, != 7.0.0,
  every version of workarea-core requires activemodel >= 5.1, < 7.1, != 7.0.0.
And because rails >= 7.1.5.1, < 7.1.5.2 depends on activemodel = 7.1.5.1,
every version of workarea-core is incompatible with rails >= 7.1.5.1, <
7.1.5.2.
So, because rails_7_1.gemfile depends on workarea-core >= 0
  and rails_7_1.gemfile depends on rails = 7.1.5.1,
  version solving has failed.
```

---

## Root Cause Analysis

This is the **same blocking dependency** documented in issue #839 for Rails 7.2:

| Constraint | Source |
|---|---|
| `mongoid ~> 7.4` | `workarea-core.gemspec` |
| `activemodel >= 5.1, < 7.1` | Mongoid 7.x upper bound on activemodel |
| `activemodel = 7.1.5.1` | Rails 7.1.5.1 requirement |

Mongoid 7.x's `activemodel < 7.1` constraint is incompatible with **both** Rails 7.1 and 7.2.
This is the well-known hard blocker: **Mongoid 8.x is required for Rails 7.x compatibility**.

### Prior Work
- Issue #690 (WA-RAILS7-004): Mongoid 8.x upgrade — currently `status:blocked, blocked:ci-failing`
- Issue #839: Same error for Rails 7.2 appraisal (documented separately)

---

## Context on Previous Admin Smoke Test (PR #1037)

Issue #1034 (merged as PR #1037) performed an admin Rails 7.1 smoke test. That test likely
used a standalone Rails app (new + app environment), not the appraisal gemfile path tested here.
The appraisal gemfile path bundles workarea-core directly and hits the Mongoid constraint.

---

## Acceptance Criteria Status

| Criteria | Status | Notes |
|---|---|---|
| Rails 7.1 appraisal boots cleanly | ❌ BLOCKED | Bundle install fails — Mongoid 7.x incompatible with Rails 7.1 |
| `bundle exec rake core_test` runs | ❌ BLOCKED | Cannot run — bundle step fails; Colima not running |
| Failures documented with root cause | ✅ | Mongoid 8.x required (see above) |

---

## Recommendation

**Unblock Mongoid 8 upgrade (issue #690) first.**

The Rails 7.1 appraisal gemfile cannot be exercised until `workarea-core.gemspec` is updated to
`mongoid ~> 8.0` (or `mongoid >= 8.0`). This is the foundational blocker for Rails 7.x
compatibility across the board.

Steps to unblock:
1. Resolve `status:blocked, blocked:ci-failing` on issue #690
2. Update `workarea-core.gemspec`: `mongoid ~> 7.4` → `mongoid ~> 8.0`
3. Update all Mongoid 8 breaking-change callsites (see WA-RAILS7-004 research doc)
4. Re-run this smoke test

---

## Environment Details

- **Ruby:** 2.7.8 (rbenv)
- **Bundler:** 2.4.22
- **Gemfile:** `gemfiles/rails_7_1.gemfile` (pins `rails = 7.1.5.1`)
- **Docker/Colima:** Not running (would have also blocked test suite execution)
- **OS:** macOS (arm64)
