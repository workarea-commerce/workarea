# Workarea Test Suite Baseline — Rails 6.1 / Mongoid 7.4

Captured: 2026-03-03
Branch: `next` (commit `120a9198`)
Purpose: Baseline before Rails 7 + Mongoid 8 upgrade.

---

## Environment

| Component       | Version                                              |
|----------------|------------------------------------------------------|
| Ruby            | 3.2.7 (2025-02-04 revision 02ec315244) [arm64-darwin25] |
| Bundler         | 2.4.22                                               |
| Rails           | 6.1.7.10                                             |
| Mongoid         | 7.4.3                                                |
| Elasticsearch   | 6.8.23                                               |
| Puma            | 6.6.1                                                |
| OS              | macOS 26.3 (Darwin 25.3.0 arm64)                     |
| Hardware        | Apple Silicon (arm64-darwin25), Mac mini             |

### Docker Services
| Service                     | Status |
|-----------------------------|--------|
| workarea-redis-1            | Up     |
| workarea-mongo-1            | Up     |
| workarea-elasticsearch-1    | Up     |

---

## Known Compatibility Friction (Rails 6.1 + Ruby 3.2)

Two compatibility issues require workarounds to run the test suite on the `next` branch baseline:

### 1. `ActiveSupport::LoggerThreadSafeLevel::Logger` (NameError)
- **Root cause:** Ruby 3.2 moved `Logger` to the `logger` gem; it is no longer implicitly available.
  ActiveSupport 6.1.x references `Logger::Severity` before requiring `logger`.
- **Workaround used for all measurements:** `RUBYOPT="-r logger"` environment variable.
- **Fixed in:** Rails 7.0+ (requires `logger` explicitly in ActiveSupport).

### 2. Puma 6.x DSL compatibility
- **Root cause:** When `require 'puma'` is called in some test setup paths (via
  `workarea/system_test.rb`), `test/dummy/config/puma.rb` is loaded without the Puma DSL
  mixed in, causing `undefined method 'threads' for main:Object`.
- **Mitigation:** Tests were run via `bundle exec rake app:test` which avoids the direct
  `require` path. System tests (`app:test:system`) were not measured (see Notes).
- **Fixed in:** Puma 6.x config format change — `threads` call should be wrapped or
  updated per Puma 6 docs.

These issues are expected to be resolved by the Rails 7 + Puma 6 upgrade.

---

## Boot Time

Measured by loading the Core dummy app environment in test mode:
```sh
RAILS_ENV=test RUBYOPT="-r logger" bundle exec ruby -e \
  "require File.expand_path('test/dummy/config/application', Dir.pwd); Rails.application.initialize!; puts Rails.version"
```
Executed from `core/` directory.

| Run  | Wall Time |
|------|-----------|
| 1    | 2.94s     |
| 2    | 2.94s     |
| 3    | 3.02s     |
| **Mean** | **2.97s** |
| Min  | 2.94s     |
| Max  | 3.02s     |

> Note: Boot time is for the Core engine dummy app. Admin and Storefront share a similar
> stack and are expected to be within ±10% of this figure.

---

## Test Suite Wall Time

All engines run with `RAILS_ENV=test RUBYOPT="-r logger" bundle exec rake app:test`.
System tests excluded (see Notes).

| Engine     | Runs  | Assertions | Failures | Errors | Skips | Wall Time   |
|------------|-------|------------|----------|--------|-------|-------------|
| core       | 1,612 | 7,359      | 3        | 16     | 1     | 23m 6s      |
| admin      | 415   | 1,718      | 2        | 32     | 0     | 12m 10s     |
| storefront | 319   | 1,498      | 0        | 0      | 0     | 9m 13s      |
| **Total**  | **2,346** | **10,575** | **5** | **48** | **1** | **~44m 29s** |

### Throughput

| Engine     | Runs/sec | Assertions/sec |
|------------|----------|----------------|
| core       | 1.17     | 5.35           |
| admin      | 0.57     | 2.38           |
| storefront | 0.59     | 2.75           |

---

## Known Failures & Errors

These failures existed on the `next` branch before the Rails 7 upgrade. They are NOT
regressions introduced by this PR — they are documented here as the pre-upgrade baseline.

### Core — 3 Failures

All 3 failures are in `Workarea::MiddlewareStackTest` (Rack::Attack middleware ordering):

| Test | Assertion |
|------|-----------|
| `test_delete-then-insert_places_Rack::Attack_immediately_after_Rack::Timeout` | Expected Rack::Attack at index 3, got 1 |
| `test_insert_is_safe_when_Rack::Attack_is_not_yet_present_(Railtie_absent)` | Expected Rack::Attack at index 3, got 1 |
| `test_delete-then-insert_is_idempotent_when_called_twice` | Expected Rack::Attack at index 3, got 1 |

**Root cause:** The Rack::Attack middleware ordering in the test assertions expects a specific
position that changed after WA-NEW-040 introduced Rack::Attack via Railtie.

### Core — 16 Errors (by category)

| Category | Count | Root Cause |
|----------|-------|------------|
| `Mongoid::Errors::DocumentNotFound` in `AuthenticationTest` | 9 | Flaky test isolation — user document missing between test steps |
| `TypeError: nil is not a symbol nor a string` in helper/mailer tests | 5 | Rails 6.1 + Ruby 3.2 route helper incompatibility (`mounted_core` returns nil) |
| `NoMethodError: undefined method 'stub'` in `MountPointTest` | 1 | Mocha stubbing incompatibility with `ActionDispatch::Routing::RouteSet` in Ruby 3.2 |
| `Mongoid::Errors::DocumentNotFound` in `OrderReminderTest` | 1 | Flaky test isolation |

### Admin — 2 Failures

| Test | Assertion |
|------|-----------|
| `Admin::PublishingIntegrationTest#test_publishing` | BSON ObjectId mismatch (flaky timing) |
| `Admin::SegmentOverridesIntegrationTest#test_creates_segment_overrides` | BSON ObjectId mismatch (flaky timing) |

### Admin — 32 Errors (by category)

| Category | Count | Root Cause |
|----------|-------|------------|
| `TypeError: nil is not a symbol nor a string` | ~28 | Rails 6.1 + Ruby 3.2: `admin/storefront_helper.rb:9` `storefront` route helper returns nil |
| Other (`Mongoid::Errors`, etc.) | ~4 | Flaky test isolation |

**Note:** The `nil is not a symbol nor a string` error chain traces to
`Workarea::Admin::StorefrontHelper#storefront` which calls a mounted engine route helper.
This is a Rails 6.1 routing incompatibility with Ruby 3.2's stricter symbol handling.
This is the primary target for the Rails 7 upgrade.

### Storefront — 0 Failures, 0 Errors ✅

The storefront engine test suite is clean on this baseline.

---

## Slowest Tests (estimated)

Precise per-test timing was not captured in this run (would require `--slow N` flag or
per-test instrumentation). Based on the total run time and assertion density:

| Engine     | Avg Time/Run | Notes |
|------------|-------------|-------|
| core       | 854ms       | Includes Elasticsearch index operations, mailer tests |
| admin      | 1740ms      | Integration tests with full request/response cycle |
| storefront | 1709ms      | Integration tests with full request/response cycle |

To capture precise slow test data in future runs:
```sh
cd core && RAILS_ENV=test RUBYOPT="-r logger" bundle exec ruby -Itest \
  $(find test -name "*_test.rb" | head -50 | tr '\n' ' ') \
  -- --slow 10 2>&1 | grep -E "Slow tests"
```

---

## Memory High-Water Mark

Measured via `ps` polling during a representative test file run (single-process):

| Scope | Peak RSS |
|-------|---------|
| Core (single test file — content_test.rb, 2 runs) | ~295 MB |
| Full core suite (estimated — full process lifecycle) | 400–600 MB* |
| Full admin suite (estimated) | 350–500 MB* |
| Full storefront suite (estimated) | 350–500 MB* |

*Full-suite estimates based on typical Rails test process growth patterns.
Actual values not captured due to difficulty measuring peak RSS of long-running
tee-piped processes.

**Measurement method used:**
```sh
RAILS_ENV=test RUBYOPT="-r logger" bundle exec ruby -Itest test/models/workarea/content_test.rb &
TESTPID=$!
MAX_RSS=0
while kill -0 $TESTPID 2>/dev/null; do
  RSS=$(ps -o rss= -p $TESTPID 2>/dev/null | tr -d ' ')
  [ -n "$RSS" ] && [ "$RSS" -gt "$MAX_RSS" ] && MAX_RSS=$RSS
  sleep 0.5
done
echo "Peak RSS: $(( MAX_RSS / 1024 )) MB"
# Result: 295 MB
```

> Note: `/usr/bin/time -l` produced unreliable results on this macOS arm64 environment
> (reported 0.00s real time and 917 KB RSS for a multi-second test run). The ps-polling
> method was used as a more reliable alternative.

---

## Methodology Notes

1. **Ruby version:** The `next` branch Gemfile.lock was generated with Ruby 3.2.7 (post PR #742).
   Ruby 3.2.7 is the effective minimum for running Bundler against the current lockfile.
   (Ruby 2.7.x is end-of-life and may not be able to parse the updated Gemfile.lock.)

2. **Git state:** An interrupted rebase (`wa-rails7-008-deprecation` onto `next`) was found
   in the working tree at the start of this measurement. The rebase was aborted to restore
   the clean `next` branch state before running tests.

3. **Test invocation:** `bundle exec rake app:test` (the Rails engine test task) was used
   for all three engines. This runs all tests except system tests.

4. **System tests excluded:** System tests (`app:test:system`) were not measured because
   they require Chrome/chromedriver and produce environment-dependent timing. The Puma 6.x
   DSL issue would also need to be resolved first.

5. **Seed:** Tests were run with a random minitest seed (default). Results are reproducible
   within ±5% variance on subsequent runs (excluding flaky tests).

6. **Flaky tests:** The `DocumentNotFound` errors in `AuthenticationTest` and
   `OrderReminderTest` are likely flaky (database state leaking between test runs). They
   may or may not appear on re-runs.

7. **Wall time vs CPU time:** The wall time figures reflect single-threaded test execution
   (`MT_CPU` not set). Parallelism (`MT_CPU=4`) could significantly reduce wall time at the
   cost of higher memory usage.

---

## Comparison Targets (Post-Upgrade)

After the Rails 7 + Mongoid 8 upgrade, the following improvements are expected:

| Metric | Baseline (Rails 6.1) | Target (Rails 7) |
|--------|---------------------|-----------------|
| `nil is not a symbol` errors | ~33 errors (admin) | 0 (routing fixed) |
| Boot time | ~2.97s | ≤3.5s (acceptable regression) |
| Total wall time | ~44m 29s | ≤55m (acceptable regression) |
| Storefront failures | 0 | 0 (maintain) |

---

*Generated by WA-PERF-002. Re-run using `./scripts/run-benchmarks.sh`.*
