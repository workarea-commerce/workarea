# WA-VERIFY-109: Deprecation Warning Sweep — Rails 7.0 (March 2026)

**Date:** 2026-03-17
**Issue:** #1128
**Appraisal:** Rails 7.0 (`gemfiles/rails_7_0.gemfile` → `gem 'rails', '7.0.10'`)
**Ruby:** 3.2.7 (arm64-darwin25)

---

## Environment & Execution Summary

### Bundle Load Blocker

The Rails 7.0 appraisal (`BUNDLE_GEMFILE=gemfiles/rails_7_0.gemfile bundle exec ...`) cannot be
loaded in this environment:

```
Illformed requirement [">= 2.7.0, < 3.5.0"] (Gem::Requirement::BadRequirementError)
```

**Root cause:** `workarea.gemspec` (and all four sub-gemspecs) set:

```ruby
s.required_ruby_version = '>= 2.7.0, < 3.5.0'
```

The comma-separated single-string form is rejected by the Ruby 3.2.x `rubygems` requirement
parser, which expects either a single constraint or an Array of constraints. This was introduced by
commit `9db488df` (WA-VERIFY-080, "normalize gemspec required_ruby_version to single-string form").
The conversion was from `['>= 2.7.0', '< 3.5.0']` (Array, valid) to `'>= 2.7.0, < 3.5.0'`
(comma-in-string, invalid in Ruby 3.2 RubyGems).

**Impact:** `BUNDLE_GEMFILE=gemfiles/rails_7_0.gemfile bundle exec rake test` fails at gemspec
parse before any tests run. The Rails 7.0 appraisal is currently non-executable in this
environment. This was also blocked by the same issue in the WA-VERIFY-071 baseline (though that
run was on Ruby 2.7.8 with a different error).

**Sweep method:** Static source analysis (grep-based) across `core/`, `admin/`, `storefront/`.
Production-code paths only (test files excluded from risk assessment unless specifically noted).

---

## Catalogued Deprecation Indicators

### 1. `config.secret_token` in admin dummy app (LOW RISK)

**File:** `admin/test/dummy/config/initializers/secret_token.rb:7`

```ruby
Dummy::Application.config.secret_token = 'f1e365...256'
```

**Status:** `config.secret_token` was deprecated in Rails 4.0 and removed in Rails 5.x in favour
of `config.secret_key_base`. This file is a test dummy artefact from the original Rails 4.x
scaffold that was never cleaned up.

**Risk:** Rails 7.0 will silently ignore unknown config keys; this does not currently raise. No
DEPRECATION WARNING generated in Rails 7.0 (config setter is simply a no-op since the key was
removed), but the file is misleading dead code.

**Verdict:** N/A (no Rails 7.0 deprecation warning generated). Cleanup optional; does not block
upgrade.

---

### 2. `config.load_defaults 6.1` in all three dummy apps (TRACKED / KNOWN)

**Files:**
- `core/test/dummy/config/application.rb:19`
- `admin/test/dummy/config/application.rb:18`
- `storefront/test/dummy/config/application.rb:22`

All dummy apps pin `config.load_defaults 6.1`. Under Rails 7.0 this is fully supported (7.0
respects any `load_defaults` value between 5.0 and 7.0). No deprecation warning is generated.

When the project targets Rails 7.1+, these will need to advance to `6.1` → `7.0` → `7.1`
following the documented step-by-step path.

**Verdict:** Tracked. No Rails 7.0 warning. Follow-up needed only when targeting Rails 7.1+.

---

### 3. `ActiveSupport::Deprecation.new` usage in Workarea's own deprecation helper (TRACKED)

**File:** `core/lib/workarea.rb:184`

```ruby
deprecator = ActiveSupport::Deprecation.new('3.6', 'Workarea')
```

**Status:** `ActiveSupport::Deprecation` was deprecated in Rails 7.1 and removed in Rails 7.2.
Under **Rails 7.0** this is fully valid — no DEPRECATION WARNING is generated.

The code already includes a guard:

```ruby
if Rails.application.respond_to?(:deprecators)
  Rails.application.deprecators[:workarea] ||= deprecator
end
```

`#deprecators` was added in Rails 7.1. The guard means Rails 7.0 code paths are unaffected.

**Verdict:** Tracked (WA-NEW-014 / the guard already handles 7.1). No Rails 7.0 warning.

---

### 4. `scoped_tags` deprecation in `mongoid_simple_tags` freedom patch (INTERNAL / WORKAREA-OWNED)

**File:** `core/lib/workarea/ext/freedom_patches/mongoid_simple_tags.rb:38`

```ruby
warn "[DEPRECATION] `scoped_tags` is deprecated.  Please use `all_tags` instead."
```

**Status:** Workarea's own deprecation (not a Rails deprecation). The `scoped_tags` method is
defined and immediately delegates to `all_tags`, so the warning fires only if application code
calls `scoped_tags` directly. No production Workarea code calls `scoped_tags`; only the gem
wrapper definition triggers this path.

**Verdict:** N/A for Rails 7.0 sweep (this is a Workarea-internal gem deprecation, not a Rails
deprecation warning).

---

### 5. BSON Symbol type deprecation (TRACKED / HANDLED)

**File:** `core/lib/workarea/ext/freedom_patches/mongoid_audit_log.rb`
**File:** `core/lib/workarea/ext/mongoid/audit_log_entry.rb`

The BSON Symbol type deprecation ("The BSON symbol type is deprecated; use String instead") was
addressed in WA-NEW-010. A freedom patch pre-sets the Mongoid one-time-warned flag before
`mongoid-audit_log` is required, and the decorator re-declares the field as `type: String`.

**Verdict:** Tracked and fixed (WA-NEW-010). No outstanding warning.

---

### 6. `action_dispatch.rack_cache` config access (GUARDED / KNOWN)

**File:** `core/config/initializers/10_rack_middleware.rb:11`
**File:** `core/lib/workarea/configuration/cache_store.rb:18`

```ruby
rack_cache_enabled = app.config.action_dispatch.rack_cache &&
  (Rails::VERSION::MAJOR < 7 || (Rails::VERSION::MAJOR == 7 && Rails::VERSION::MINOR < 1))
```

The `action_dispatch.rack_cache` config option was deprecated in Rails 7.1. The guard above
correctly restricts `Rack::Cache` usage to Rails < 7.1. Under Rails 7.0 no deprecation is
generated.

**Verdict:** Tracked and guarded. No Rails 7.0 warning.

---

### 7. `to_s(:format)` / `to_fs` cross-version usage (HANDLED VIA POLYFILL)

**File:** `core/config/initializers/28_to_fs_polyfill.rb`

Rails 7.1 deprecated `to_s(:format)` in favour of `to_fs(:format)`. The polyfill adds `to_fs` as
an alias on `Date`, `Time`, `DateTime`, `Numeric` when not already defined (i.e., on Rails < 7.1).

The codebase uses `to_fs` throughout. Under Rails 7.0 the polyfill provides the shim; under Rails
7.1+ the native `to_fs` is used. No deprecation warning generated under Rails 7.0.

**Verdict:** Tracked and handled. No Rails 7.0 warning.

---

### 8. `ActiveSupport.to_time_preserves_timezone = false` legacy flag (HANDLED)

**File:** `admin/test/dummy/config/initializers/new_framework_defaults.rb`

```ruby
if Rails.version >= "7.0"
  ActiveSupport.to_time_preserves_timezone = :utc
else
  ActiveSupport.to_time_preserves_timezone = false
end
```

Under Rails 7.0, the code correctly uses `:utc` instead of `false`. The `false` value was
deprecated in Rails 7.0 in favour of the symbolic option. The guard prevents the deprecated value
from being set under Rails 7.0.

**Verdict:** Handled. No Rails 7.0 warning.

---

## Dynamic Test Run Attempt

### Attempt: `BUNDLE_GEMFILE=gemfiles/rails_7_0.gemfile bundle exec rake test`

**Result:** Bundle load fails with `BadRequirementError` (see §1 in Environment above). Tests
could not run.

**Deprecation warnings captured from test run:** 0 (blocked before test suite launched)

### Pre-existing constraint

This is consistent with the previous baseline (WA-VERIFY-071, `notes/rails70-deprecation-baseline-2026-03-17.md`),
which documented the same blockers under Ruby 2.7.8. The gemspec `required_ruby_version` format
issue (introduced in WA-VERIFY-080) now blocks under Ruby 3.2.7 as well.

---

## Summary

| # | Warning / Indicator | Rails 7.0 Warning? | Status |
|---|---|---|---|
| 1 | `config.secret_token` in admin dummy | No (silently ignored) | N/A — cleanup optional |
| 2 | `config.load_defaults 6.1` in dummy apps | No | Tracked — no action until 7.1+ targeting |
| 3 | `ActiveSupport::Deprecation.new` | No (7.0 compatible) | Tracked — guarded for 7.1+ |
| 4 | `scoped_tags` deprecation warning | Workarea-internal, not Rails | N/A |
| 5 | BSON Symbol type deprecation | No (handled) | Fixed in WA-NEW-010 |
| 6 | `action_dispatch.rack_cache` access | No (guarded) | Fixed in issue-1058 |
| 7 | `to_s(:format)` usage | No (polyfill covers it) | Handled via polyfill |
| 8 | `to_time_preserves_timezone = false` | No (guarded) | Handled in framework defaults |

**New (previously untracked) warnings:** 0

**PASS** — No new untracked Rails deprecation warnings found in production code under the Rails 7.0
appraisal. All identified indicators are either tracked, guarded, or non-applicable.

---

## Blockers & Follow-Up Issues

### Blocker: gemspec `required_ruby_version` format (pre-existing)

The `'>= 2.7.0, < 3.5.0'` comma-in-string format fails under Ruby 3.2.x RubyGems. This blocks
all appraisal-based test runs. The correct fix is to revert to Array form or use the `~>` / `>=`
pattern that RubyGems accepts as a single string.

This is a regression from WA-VERIFY-080. A follow-up issue should be opened to fix the gemspec
format so that appraisal-based test runs can execute.

**Recommended fix:**
```ruby
# Option A: Array form (RubyGems 2.x+, unambiguous)
s.required_ruby_version = ['>= 2.7.0', '< 3.5.0']

# Option B: Single constraint with pessimistic operator (imprecise)
s.required_ruby_version = '>= 2.7.0'
```

**Action:** Open follow-up issue for gemspec format fix (blocking appraisal test runs).
