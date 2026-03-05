# WA-VERIFY-004: Post-Rails-7 Performance Baseline

**Branch:** `wa-verify-004-perf-baseline`
**Date:** 2026-03-05
**Ruby:** 3.2.7
**Rails:** 6.1.7.10 (active on `next` branch — Rails 7 migration in progress)

## Environment

| Service        | Status  | Version     |
|---------------|---------|-------------|
| MongoDB        | ✅ Up   | (via Docker) |
| Elasticsearch  | ✅ Up   | (via Docker) |
| Redis          | ✅ Up   | (via Docker) |
| Ruby           | 3.2.7   | rbenv       |

## Test Suite Timing Results

| Suite       | Runs | Passing | Errors | Test Duration | Total Elapsed | Avg/Test |
|------------|------|---------|--------|--------------|--------------|---------|
| Core        | 1613 | 4       | 1609   | 6.4s         | 32s          | ~0.02s  |
| Admin       | 415  | 0       | 415    | 790.9s       | 811s         | ~1.9s   |
| Storefront  | 319  | 5       | 314    | 541.5s       | 560s         | ~1.7s   |
| **Total**   | **2347** | **9** | **2338** | **~1338s** | **~1403s** | — |

## App Boot Time

| Measurement                     | Duration |
|--------------------------------|---------|
| `bundle exec rails runner "puts Rails.version"` (core dummy app) | **4.1s** |

## Error Analysis

> ⚠️ **All suites show failures.** Root cause is a pre-existing test environment configuration issue, **not** a measurement artifact.

### Primary Error

```
RuntimeError: Refusing to truncate Mongoid clients outside test environment
    testing/lib/workarea/test_case.rb:265 in `truncate_all_mongoid_clients!'
```

The test harness's `setup` hook calls `truncate_all_mongoid_clients!`, which guards against running outside `Rails.env.test?`. When the rake task runs tests via the engine, `RAILS_ENV` is not being properly propagated to the guard.

### Secondary Error (cascades from setup failure)

```
NoMethodError: undefined method `[]' for nil:NilClass
    testing/lib/workarea/test_case.rb:63 in teardown
```

This is a teardown cascade — when setup fails, teardown accesses config values through a nil reference.

### Error Distribution by Type (Core suite)

| Error Type                                         | Count |
|---------------------------------------------------|-------|
| `Refusing to truncate Mongoid clients outside test env` | 1452  |
| `undefined method '[]' for nil:NilClass` (teardown cascade) | 1389  |
| `undefined method 'send_email=' for nil`           | 166   |
| `undefined method 'auto_refresh_search=' for nil`  | 156   |
| `undefined method 'countries=' for nil`            | 7     |
| `NameError: constant Workarea::Payment::Tender::Foo not defined` | 6 |
| Other `NoMethodError` variants                     | ~33   |

## Slow Test Identification (> 5s)

The Admin suite averaged **~1.9s per error** (790.9s / 415 runs), indicating test infrastructure overhead per invocation. Individual slow tests could not be isolated from this run because tests fail in `setup` (before test body executes), so duration is setup+teardown overhead only.

Notably:
- **Admin suite**: 415 runs × avg 1.9s overhead = significant per-test fixture setup cost
- **Storefront suite**: 319 runs × avg 1.7s overhead = similar overhead profile
- **Core suite**: 1613 runs in 6.4s = ~0.004s per test — minimal setup overhead (tests error almost immediately in setup, no wait on external services)

The Admin and Storefront suites show substantially higher per-test overhead, consistent with integration tests making HTTP requests to the Rails stack before the Mongoid guard fires.

## Notes for Future Comparison

This baseline was captured on `next` at commit `0a6da76a` after Rails 7 migration work. When comparing future runs:

1. **The Mongoid test environment error must be resolved first** — current error rate (99.6% in core, 100% in admin, 98.4% in storefront) makes meaningful comparison impossible until the root issue is fixed
2. **App boot of 4.1s** is the cleanest single-value baseline — compare post-merge
3. **Suite load time differential**: Core loads (and errors) in 6.4s; Admin/Storefront take 790s/541s because they run integration tests that fully boot the stack before each test failure

## Recommended Follow-Up

- [ ] Fix `RAILS_ENV=test` propagation in engine rake task (separate issue)
- [ ] Re-run baseline after fix to get clean pass/fail numbers
- [ ] Track individual slow tests (> 5s) once pass rate is meaningful
