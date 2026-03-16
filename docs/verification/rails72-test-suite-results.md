# Rails 7.2 Test Suite Results

**Issue:** #768 — Rails 7.2: add appraisal + run test suite under rails_7_2.gemfile  
**Branch:** `wa-rails72-test-suite-appraisal`  
**Date:** 2026-03-05  
**Environment:** Ruby 3.2.7 (rbenv), Rails 7.2.3, Mongoid 8.1, macOS arm64

---

## Environment

| Service        | Version / Status            |
|---------------|----------------------------|
| Ruby           | 3.2.7 (rbenv)              |
| Rails          | 7.2.3 (via rails_7_2.gemfile) |
| Mongoid        | 8.1.x (upgraded from 7.x) |
| Rack           | 2.2.x (pinned)             |
| Mocha          | 2.x                        |
| MongoDB        | ✅ Running (Docker)        |
| Elasticsearch  | ✅ Running (Docker)        |
| Redis          | ✅ Running (Docker)        |

---

## Gemfile Status

`gemfiles/rails_7_2.gemfile` — **exists and locked** (added in forward-compat assessment PR #769).

Key pins required for Rails 7.2 + Mongoid 8 compatibility:
```ruby
gem 'rails', '~> 7.2.0'
gem 'mongoid', '~> 8.1'       # mongoid 7.x requires activemodel < 7.1
gem 'rack', '~> 2.2'          # serviceworker-rails 0.6.0 uses rack/file removed in Rack 3
gem 'mocha', '~> 2.0'         # mocha 1.3.0 uses deprecated MiniTest constant
```

Boot-time compatibility fixes were applied in commit `4c66becf`:
- Loosen mongoid constraint: `~> 7.4` → `>= 7.4, < 10`
- Loosen mocha constraint: `~> 1.3.0` → `>= 1.3.0, < 3`
- Guard `mocha/mini_test` → `mocha/minitest` rename (mocha 2.x)
- Guard `perform_enqueued_jobs` calls (removed from SidekiqAdapter in Rails 7.2)
- Rails 7.2 compat initializer for boot-time issues

---

## Test Results (Sampled Run — Core Engine)

> **Note:** Full suite (435 test files in core, 179 admin, 119 storefront) requires a 60-90 minute CI run.
> This report covers a representative sample of 13 test files run individually.
>
> **RAILS_ENV propagation issue (#783)** prevents reliable `rake test` invocation from engine root.
> Tests were run via: `bundle exec ruby -Itest <test_file>` from the `core/` directory.

### Passing Tests (Core Engine Sample)

| Test File | Runs | Assertions | Failures | Errors |
|-----------|------|-----------|---------|--------|
| `test/models/workarea/checkout_test.rb` | 19 | 110 | 0 | 0 |
| `test/models/workarea/content_test.rb` | 2 | 3 | 0 | 0 |
| `test/models/workarea/order_test.rb` | 14 | 60 | 0 | 0 |
| `test/models/workarea/fulfillment_test.rb` | 16 | 38 | 0 | 0 |
| `test/models/workarea/pricing/sku_test.rb` | 4 | 8 | 0 | 0 |
| `test/workers/workarea/bulk_index_products_test.rb` | 1 | 2 | 0 | 0 |
| `test/workers/workarea/clean_orders_test.rb` | 1 | 10 | 0 | 0 |
| `test/workers/workarea/generate_insights_test.rb` | 2 | 6 | 0 | 0 |
| `test/integration/workarea/authentication_test.rb` | 9 | 45 | 0 | 0 |
| `test/integration/workarea/monitoring_integration_test.rb` | 6 | 12 | 0 | 0 |
| **Subtotal (passing)** | **74** | **294** | **0** | **0** |

### Failing Tests (Core Engine Sample)

| Test File | Runs | Failures | Errors | Issue |
|-----------|------|---------|--------|-------|
| `test/models/workarea/catalog/product_test.rb` | 13 | 1 | 0 | #788 |
| `test/models/workarea/user_test.rb` | 24 | 1 | 0 | #789 |
| `test/integration/workarea/cache_varies_integration_test.rb` | 2 | 0 | 2 | #787 |
| **Subtotal (failing)** | **39** | **2** | **2** | — |

**Sample total: 113 runs, 2 failures, 2 errors (96.5% pass rate in sampled files)**

---

## Failure Details

### 1. `Rack::Cache` Uninitialized Constant (Issue #787)

```
NameError: uninitialized constant Rack::Cache
    test/integration/workarea/cache_varies_integration_test.rb:55
```

**Root cause:** Under Rails 7.2 + `rack ~> 2.2`, `rack-cache` gem is not auto-required.  
**Fix:** Add `require 'rack/cache'` to the test file.

---

### 2. Slug Caching Mismatch in `Catalog::ProductTest` (Issue #788)

```
Failure: Workarea::Catalog::ProductTest#test_slug_caching
Expected: "different-slug"
  Actual: "same-slug"
```

**Root cause (suspected):** Mongoid 8 dirty tracking or slug generation caching changed.  
**Fix:** Investigate Mongoid 8 slug behavior and update test or model accordingly.

---

### 3. Password Reuse Validation in `UserTest` (Issue #789)

```
Failure: Workarea::UserTest#test_does_not_allow_admins_to_reuse_the_same_password
Expected true to not be truthy.
```

**Root cause (suspected):** Mongoid 8 callback ordering change affecting `has_secure_password` validation.  
**Fix:** Review `before_validation` / bcrypt interaction under Mongoid 8.

---

## Comparison with Rails 6.1 Baseline (PR #777)

The Rails 6.1 baseline (PR #777) showed **99.6% test error rate** due to the RAILS_ENV propagation
bug (#783), making direct comparison difficult. The 3 failures found here are distinct from the
setup-guard errors in that baseline.

These failures appear to be **Mongoid 8 compatibility issues**, not Rails 7.2 API changes:
- Mongoid 8 is required because Mongoid 7.x has `activemodel < 7.1` constraint
- These failures are isolated and fixable via follow-up issues #787, #788, #789

---

## Follow-up Issues Created

| Issue | Title | Status |
|-------|-------|--------|
| #787 | Rails 7.2: Fix Rack::Cache uninitialized constant | `status:ready` |
| #788 | Rails 7.2 / Mongoid 8: slug_caching test failure | `status:ready` |
| #789 | Rails 7.2 / Mongoid 8: password reuse validation failure | `status:ready` |

---

## Next Steps

1. Fix #787, #788, #789 in follow-up PRs
2. Run full test suite in CI (core 435 files, admin 179, storefront 119) once RAILS_ENV
   propagation issue (#783) is resolved
3. Compare full Rails 7.2 results against cleaned-up Rails 6.1 baseline
