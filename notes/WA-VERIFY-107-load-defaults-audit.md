# WA-VERIFY-107 — `config.load_defaults` Behavioral Flags Audit (Rails 7.0 / 7.1)

**Date:** 2026-03-17
**Auditor:** automated (impl-1126-verify-107)
**Issue:** workarea-commerce/workarea#1126
**Pattern doc cross-reference:** `docs/rails7-migration-patterns/bigdecimal-money-serialization.md`,
`docs/rails7-migration-patterns/middleware-stack-ordering.md`,
`docs/rails7-migration-patterns/load-defaults-7-2.md`

---

## 1. Current `load_defaults` Setting (All Engine Dummy Apps)

| Engine | File | Value |
|--------|------|-------|
| `core` | `core/test/dummy/config/application.rb:19` | `config.load_defaults 6.1` |
| `admin` | `admin/test/dummy/config/application.rb:18` | `config.load_defaults 6.1` |
| `storefront` | `storefront/test/dummy/config/application.rb:22` | `config.load_defaults 6.1` |

**Status: PASS** — All three dummy apps are consistently pinned to `6.1`.  This is intentional and
tracked in WA-VERIFY-003 / PR #775.  Upgrading to `7.0` or `7.1` is a follow-up task that requires
the Mongoid 8 upgrade to complete first (see issue #841).

---

## 2. Rails 7.0 Behavioral Flags

The Rails 7.0 versioned defaults introduce the following changes relevant to Workarea.

### 2.1 `config.action_dispatch.cookies_same_site_protection = :lax`
**Workarea impact:** Low.  Workarea sets its own session cookie options via
`Workarea.config.session_options`.  The default `SameSite=Lax` is compatible with Workarea's
storefront and admin flows, which do not use cross-site POST forms that require `SameSite=None`.
No test gap identified.
**Status: N/A** — Workarea relies on host-app config; default is safe for standard deployments.

### 2.2 `config.active_support.key_generator_hash_digest_class = OpenSSL::Digest::SHA256`
**Workarea impact:** Low–medium.  Rails 7.0 changed the default key-generator digest from SHA1 to
SHA256.  This affects signed/encrypted cookies and ActiveSupport::MessageEncryptor payloads.
Workarea does not currently store custom encrypted-cookie payloads; session data is stored
server-side (Redis).  Rolling-deploy risk: existing encrypted cookies from Rails 6.1 sessions will
become invalid after upgrading (users are logged out).  This is acceptable one-time breakage during
upgrade.
**Test coverage:** No specific round-trip test for session encryption exists in Workarea's test
suite, but this is a standard Rails upgrade concern documented in the Rails upgrade guide.
**Status: N/A for Workarea core** — Downstream apps using custom MessageEncryptor payloads may need
the transitional `config.active_support.key_generator_hash_digest_class = OpenSSL::Digest::SHA1`
shim.  Document in migration notes for downstream apps.

### 2.3 `config.action_controller.raise_on_open_redirects = true`
**Workarea impact:** Medium.  Workarea contains redirect helpers (e.g. return-to URL, post-login
redirect, admin action redirect).  If any of these use unsanitized URL parameters, upgrading to
`load_defaults 7.0` will surface `ActionController::Redirecting::UnsafeRedirectError`.
**Test coverage:**
```
grep -rn 'redirect_to\|return_to\|redirect_back' core/app/ admin/app/ storefront/app/ --include='*.rb'
```
Workarea's `Workarea::Routing::Redirect` and storefront return-path handling do constrain redirect
targets, but this is not covered by a dedicated test that verifies open-redirect prevention under
the `raise_on_open_redirects = true` default.
**Status: NEEDS-FOLLOW-UP** — Open a targeted verification issue to confirm no open-redirect
paths exist in Workarea controllers before enabling this flag.

### 2.4 `config.action_dispatch.request_id_format = :uuid`
**Workarea impact:** Negligible.  Workarea does not depend on the request-id format internally.
**Status: N/A**

### 2.5 `config.active_record.partial_inserts = false`
**Workarea impact:** N/A — Workarea core uses Mongoid, not ActiveRecord.  Downstream apps with AR
models may be affected.
**Status: N/A for Workarea core**

---

## 3. Rails 7.1 Behavioral Flags

### 3.1 `config.active_job.use_big_decimal_serializer = true`
**Workarea impact:** Medium.  Workarea enqueues ActiveJob jobs that carry `Money` / `BigDecimal`
arguments (e.g. pricing cache updates, discount application workers).  Under `load_defaults 7.1`
BigDecimal job arguments use a dedicated `ActiveJob::Serializers::BigDecimalSerializer` rather than
converting to String.  A rolling deploy across a `7.0` → `7.1` boundary could produce jobs where
enqueued payloads use the new serializer but consumer workers still run the old code (or vice
versa).
**Test coverage:** No specific test exists that verifies `BigDecimal` job argument round-trips.
The `bigdecimal-money-serialization.md` pattern doc covers cache serialization but not ActiveJob
argument serialization.
**Status: NEEDS-FOLLOW-UP** — Before bumping `load_defaults` to `7.1`, add a test confirming that
Workarea jobs with `BigDecimal`/`Money` arguments survive round-trip through Redis (or inline
adapter) without precision loss.  Tag with `rails7-upgrade`.

### 3.2 `config.active_support.cache_format_version = 7.1`
**Workarea impact:** High if shared cache is used during upgrade window.  Rails 7.1 changed the
ActiveSupport cache entry format; caches written by 7.0 cannot be read by 7.1 and vice versa.
Workarea uses Redis as its primary cache store.  A rolling deploy without a cache flush will cause
intermittent `TypeError` or nil cache misses during the transition window.
**Test coverage:** The `bigdecimal-money-serialization.md` pattern doc calls out the cache format
change and recommends flushing pricing cache keys.  No automated test verifies the format upgrade
path.
**Status: N/A for test suite** — This is a deployment-procedure concern, not a Workarea code
defect.  It is documented in the migration pattern doc.  Downstream apps should flush their cache
or accept temporary misses during the upgrade window.  Add a note to `upgrading-to-rails-7.md`.

### 3.3 `config.active_record.run_commit_callbacks_on_first_saved_instances_in_transaction = false`
**Workarea impact:** N/A — Workarea core uses Mongoid, not ActiveRecord.
**Status: N/A**

### 3.4 `config.active_record.belongs_to_required_validates_foreign_key = false`
**Workarea impact:** N/A — Mongoid only.
**Status: N/A**

### 3.5 `config.active_support.message_serializer = :json_allow_marshal`
**Workarea impact:** Low.  Affects `MessageEncryptor` / `MessageVerifier` payloads.  Workarea does
not produce signed messages that persist beyond a single request/response cycle.
**Status: N/A for Workarea core**

### 3.6 `config.add_autoload_paths_to_load_path = false` (7.1 default)
**Workarea impact:** Medium.  If any Workarea engine or downstream plugin has code that calls
`require` on autoloaded paths (instead of using the autoloader), those calls will fail under 7.1.
**Test coverage:** The Zeitwerk audit (`docs/rails7-migration-patterns/zeitwerk-notes.md`) covers
this generally.  The `tmp/wa-verify-023/` sandboxes set `config.load_defaults 7.0` (not yet 7.1).
**Status: NEEDS-FOLLOW-UP** — Once Mongoid 8 unblocks the 7.1 appraisal, run the test suite with
`config.add_autoload_paths_to_load_path = false` explicitly set to surface any `require`-based
failures.

### 3.7 `config.action_dispatch.default_headers` — removal of `X-Download-Options`
**Workarea impact:** Negligible.  This header is IE-specific and Workarea no longer targets IE.
**Status: N/A**

### 3.8 `config.action_controller.allow_deprecated_parameters_hash_equality = false`
**Workarea impact:** Low–medium.  Workarea parameter handling occasionally compares params against
Hash literals in legacy controllers.  Under 7.1 this raises `ArgumentError`.  
**Test coverage:** No targeted test; covered implicitly by the full controller test suite.
**Status: NEEDS-FOLLOW-UP** — Run integration suite with this flag enabled and triage failures.

---

## 4. QueryCache Middleware Position

**Finding:** `Mongoid::QueryCache::Middleware` and `Workarea::Elasticsearch::QueryCache::Middleware`
are inserted via `core/config/initializers/10_rack_middleware.rb` using `app.config.middleware.use`,
which appends them **after** the Rails default stack.  This is the correct position — query caches
wrap the entire request/response lifecycle inside the Rack stack.

**Test coverage:**
- `core/test/middleware/workarea/rack_middleware_stack_test.rb` verifies both middleware are
  **present** in the stack.
- `core/test/lib/mongo/query_cache_middleware_test.rb` verifies the middleware **clears the cache
  between requests** (no cross-request leakage).
- `core/test/mongo_query_cache_smoke_test.rb` verifies the `Mongo::QueryCache` API surface is
  callable.

**No test verifies the absolute *position* of QueryCache middleware relative to `ActiveRecord::QueryCache`** (which is irrelevant for Workarea since it uses Mongoid, not ActiveRecord).  The
existing tests are sufficient for Workarea's usage.

**Status: PASS**

---

## 5. BigDecimal / Money Cache Serialization

**Finding:** `grep -rn 'BigDecimal|to_money|Money.new' core/test/ storefront/test/ admin/test/ --include='*.rb' | grep -i cache` returns **no results**.  There are no dedicated cache round-trip
tests for `BigDecimal` or `Money` objects.

The pattern doc `docs/rails7-migration-patterns/bigdecimal-money-serialization.md` documents the
risk and recommends flushing the `workarea:pricing:*` Redis namespace during upgrade, but there is
no automated regression test confirming that a `Money`/`BigDecimal` value written to cache can be
read back as the correct type under the target Rails version.

**Status: NEEDS-FOLLOW-UP** — Create a targeted test in `core/test/` that:
1. Writes a `Workarea::Money` and a raw `BigDecimal` to `Rails.cache`
2. Reads them back and asserts the type and value are preserved
3. Is skipped or noted when running under `load_defaults 6.1` (current baseline)

This test gap means silent precision loss could occur at the cache layer without test-suite
detection.  Suggest tagging the follow-up issue `rails7-upgrade` + `priority:high`.

---

## 6. Summary Table

| Flag / Behavior | Rails version introduced | Workarea status |
|---|---|---|
| `cookies_same_site_protection = :lax` | 7.0 | N/A |
| `key_generator_hash_digest_class = SHA256` | 7.0 | N/A (session flush on upgrade) |
| `raise_on_open_redirects = true` | 7.0 | **NEEDS-FOLLOW-UP** |
| `request_id_format = :uuid` | 7.0 | N/A |
| `active_record.partial_inserts = false` | 7.0 | N/A (Mongoid) |
| `active_job.use_big_decimal_serializer` | 7.1 | **NEEDS-FOLLOW-UP** |
| `active_support.cache_format_version = 7.1` | 7.1 | N/A (deploy procedure) |
| `run_commit_callbacks_on_first_saved...` | 7.1 | N/A (Mongoid) |
| `belongs_to_required_validates_foreign_key` | 7.1 | N/A (Mongoid) |
| `active_support.message_serializer` | 7.1 | N/A |
| `add_autoload_paths_to_load_path = false` | 7.1 | **NEEDS-FOLLOW-UP** |
| `action_dispatch.default_headers` (IE drop) | 7.1 | N/A |
| `allow_deprecated_parameters_hash_equality` | 7.1 | **NEEDS-FOLLOW-UP** |
| QueryCache middleware position | — | **PASS** (tested) |
| BigDecimal/Money cache round-trip | — | **NEEDS-FOLLOW-UP** (no test) |

### PASS (2)
- `load_defaults` version confirmed as `6.1` in all three engine dummy apps
- QueryCache middleware presence and no-leak behavior tested

### N/A (9)
- All ActiveRecord-only flags (Workarea uses Mongoid)
- `cookies_same_site_protection` (compatible with Workarea flows)
- `key_generator_hash_digest_class` (accept session invalidation on upgrade)
- `cache_format_version` (deploy-procedure concern, documented)
- `message_serializer` (not used for persistent payloads)

### NEEDS-FOLLOW-UP (4)
1. `raise_on_open_redirects` — verify no open-redirect paths in Workarea controllers
2. `active_job.use_big_decimal_serializer` — add job argument round-trip test
3. `add_autoload_paths_to_load_path = false` — run suite with flag enabled after Mongoid 8
4. `allow_deprecated_parameters_hash_equality` — run integration suite with flag enabled
5. BigDecimal/Money cache round-trip — add explicit regression test

---

## 7. Recommended Follow-up Issues

| Title | Priority | Labels |
|---|---|---|
| Add `BigDecimal`/`Money` cache round-trip regression test | high | `rails7-upgrade`, `test` |
| Verify no open-redirect paths before enabling `raise_on_open_redirects` | medium | `rails7-upgrade`, `security` |
| Add `ActiveJob` BigDecimal argument round-trip test for 7.1 | medium | `rails7-upgrade`, `test` |
| Run suite with `add_autoload_paths_to_load_path = false` (after Mongoid 8) | low | `rails7-upgrade`, `blocked:mongoid8` |

---

*End of audit.*
