# Mongoid 8.x Migration Guide

*Updated: 2026-03-02 — WA-RAILS7-004*

This document describes the changes made to make Workarea compatible with Mongoid 8.x, and what host application developers need to know when upgrading.

---

## Overview

Workarea's `mongoid` dependency has been widened from `~> 7.4` to `>= 7.4, < 9`:

```ruby
# Before
s.add_dependency 'mongoid', '~> 7.4'

# After
s.add_dependency 'mongoid', '>= 7.4', '< 9'
```

**Minimum version for Rails 7 support: Mongoid 8.1.3** (formally adds Rails 7.0/7.1 support).

---

## Breaking Changes in Workarea Core

### 1. `update_attributes` / `update_attributes!` Removed

Mongoid 8.0 removes `update_attributes` and `update_attributes!` (deprecated since Mongoid 7.x, mirroring ActiveRecord's Rails 6.1 deprecation).

**Change applied in this PR:** All ~550 occurrences across core, admin, storefront, and testing have been mechanically renamed:

| Old | New |
|-----|-----|
| `.update_attributes(attrs)` | `.update(attrs)` |
| `.update_attributes!(attrs)` | `.update!(attrs)` |

**If you have Workarea plugins or host application code** using `update_attributes` or `update_attributes!` on Mongoid models, you must update these before upgrading to Mongoid 8.x.

```bash
# Find all occurrences in your app
grep -rn "\.update_attributes" --include="*.rb" . | grep -v vendor
```

### 2. `Mongoid::QueryCache` Replaced by `Mongo::QueryCache`

Mongoid 8.x deprecates `Mongoid::QueryCache` and Mongoid 9.x removes it entirely. The replacement is `Mongo::QueryCache` from the `mongo` driver gem (available since mongo driver 2.14, which is bundled with Mongoid 7.4+).

**Changes applied in this PR:**

| Location | Old | New |
|----------|-----|-----|
| `core/config/initializers/10_rack_middleware.rb` | `Mongoid::QueryCache::Middleware` | `Mongo::QueryCache::Middleware` |
| `core/app/queries/workarea/admin_search_query_wrapper.rb` | `Mongoid::QueryCache.clear_cache` | `Mongo::QueryCache.clear` |
| `core/app/models/workarea/releasable.rb` | `Mongoid::QueryCache.uncached { }` | `Mongo::QueryCache.uncached { }` |

If your host application or plugins use `Mongoid::QueryCache` directly, update them:

```ruby
# Before
Mongoid::QueryCache.clear_cache
Mongoid::QueryCache.uncached { ... }
Mongoid::QueryCache::Middleware

# After
Mongo::QueryCache.clear
Mongo::QueryCache.uncached { ... }
Mongo::QueryCache::Middleware
```

### 3. Default Configuration Behavior Changes (load_defaults shim)

Mongoid 8.0 changed the defaults for many configuration flags that were previously opt-in under Mongoid 7.x (e.g. `broken_aggregables`, `broken_alias_handling`, `broken_and`, `broken_scoping`, `broken_updates`, `compare_time_by_ms`, `legacy_attributes`, `legacy_pluck_distinct`, `legacy_triple_equals`, `object_id_as_json_oid`, `overwrite_chained_operators`).

**Change applied in this PR:** Workarea's `Configuration::Mongoid.load` now automatically calls `Mongoid.load_defaults('7.5')` when running under Mongoid 8+. This preserves legacy behavior during the upgrade period.

```ruby
# core/lib/workarea/configuration/mongoid.rb
if ::Mongoid::VERSION.to_i >= 8
  ::Mongoid.load_defaults('7.5') if ::Mongoid.respond_to?(:load_defaults)
end
```

**Action for host applications:** After verifying your application works with Mongoid 8, incrementally adopt new defaults by calling `Mongoid.load_defaults('8.0')` (then `'8.1'`) in your initializer. See the [Mongoid upgrade guide](https://www.mongodb.com/docs/mongoid/current/reference/upgrading/) for details on what each version changes.

---

## Not-Yet-Breaking Changes (Mongoid 9 Notes)

The following are **not breaking in Mongoid 8** but will become breaking in Mongoid 9. Note these for a future upgrade:

### `around_*` Callbacks on Embedded Documents

Mongoid 9.0 silently ignores `around_save`, `around_create`, `around_update`, `around_destroy` callbacks defined on embedded documents by default. Re-enabling them via `Mongoid.around_callbacks_for_embeds = true` is possible but risks `SystemStackError`.

**Workarea core audit:** The two models with `around_*` callbacks (`Release::Activation` and `Search::Settings`) are **not embedded documents**, so core is not affected. However, **plugin or host application embedded models** should be audited:

```bash
# Find around_* callbacks on embedded models
grep -rn "around_save\|around_create\|around_update\|around_destroy" app/models/ --include="*.rb"
# Cross-reference with embedded document declarations:
grep -rn "embedded_in\|embeds_many\|embeds_one" app/models/ --include="*.rb"
```

### `load_defaults '7.5'` Removed in Mongoid 9

Mongoid 9 only accepts `load_defaults '8.0'` or later. Before upgrading to Mongoid 9, remove the `7.5` shim from your Mongoid configuration and address any behavioral changes from adopting Mongoid 8 defaults.

### `AttributeNotLoaded` Error Type Change

Code rescuing `ActiveModel::MissingAttributeError` in Mongoid model contexts should be updated to rescue `Mongoid::Errors::AttributeNotLoaded` for Mongoid 9 compatibility.

---

## Plugin Compatibility

Several Mongoid-dependent plugins used by Workarea may require patching for Mongoid 8 compatibility. As of the research date (2026-02-28), these plugins carry **high risk**:

| Gem | Risk | Notes |
|-----|------|-------|
| `mongoid-audit_log` | HIGH | Authored by @bencrouse; no official Mongoid 8 release. May need forking. |
| `mongoid-document_path` | HIGH | Authored by weblinc; unmaintained upstream. |
| `mongoid-encrypted` | HIGH | Uses Mongoid field internals; type system changes in 8.x may break. |
| `mongoid-active_merchant` | MEDIUM | Small adapter; may use `update_attributes`. |
| `mongoid-tree` | MEDIUM | Community gem; check RubyGems for 8.x compat release. |
| `kaminari-mongoid` | LOW | Actively maintained; likely has Mongoid 8 support. |
| `mongoid-sample` | LOW | Minimal gem; basic Mongoid API only. |

Plugin compatibility work is tracked separately. See the research doc at `docs/research/mongoid-upgrade-path.md` for full details.

---

## BigDecimal / Money Fields

Mongoid 8 introduces a `map_big_decimal_to_decimal128` feature flag that changes how `BigDecimal` fields are stored in MongoDB. **Do not enable this flag** without a data migration plan. Workarea's `Money` fields (`Order::Item#total_value`, `Order::Item#total_price`, etc.) rely on `money-rails` + Mongoid type coercion.

The `load_defaults '7.5'` shim applied above preserves the legacy `BigDecimal` behavior. Only enable `map_big_decimal_to_decimal128` after verifying `money-rails` compatibility and planning a data migration.

---

## Upgrade Checklist

- [ ] Upgrade `mongoid` gem to `~> 8.1` in your `Gemfile.lock` (via `bundle update mongoid`)
- [ ] Replace any `update_attributes`/`update_attributes!` calls in your host app code
- [ ] Replace any `Mongoid::QueryCache` references in your host app
- [ ] Run your test suite; address any Mongoid 8 behavioral regressions
- [ ] Audit plugins for Mongoid 8 compatibility (see table above)
- [ ] Gradually adopt new Mongoid 8 defaults via `load_defaults '8.0'` after verifying behavior

---

*Related issue: [#690](https://github.com/workarea-commerce/workarea/issues/690)*
*Research doc: [docs/research/mongoid-upgrade-path.md](research/mongoid-upgrade-path.md)*
