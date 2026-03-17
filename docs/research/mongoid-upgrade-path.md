# Mongoid 8/9 Upgrade Path — Workarea

*Researched: 2026-02-28*

## Summary

Upgrading Workarea's Mongoid dependency from `~> 7.4.0` to 8.x or 9.x is **required** for Rails 7 support. This is a **hard cut** — Mongoid 7.x is incompatible with Rails 7. Mongoid 8.0 introduced Rails 6.0 support (minimum), and Mongoid 8.1.3+ formally added Rails 7.1 support. Mongoid 9.0 also supports Rails 6.0+.

The upgrade carries **medium-high risk** due to:
1. 148 files using `update_attributes!` (deprecated/removed in Mongoid 8)
2. Workarea's use of `Mongoid::QueryCache` (removed in Mongoid 9, renamed in 8)
3. Several Mongoid plugin dependencies with uncertain Mongoid 8+ compatibility (see below)

**Recommended target: Mongoid 8.1.x** (latest 8.x stable, full Rails 7.0/7.1 support, stepping stone before 9.x).

---

## Mongoid 7.4 → 8.x Breaking Changes

Source: official Mongoid 8.0 release notes and changelogs.

### Rails Requirement
- **Mongoid 8.0 requires Rails 6.0+**. Rails 5.x and earlier are not supported.

### Default Configuration Value Changes (behavior changes, not removals)
The following config flags had their **defaults changed** in 8.0 (previously opt-in, now the default). Apps relying on legacy behavior must explicitly set them:
- `use_activesupport_time_zone` → default changed
- `broken_aggregables`, `broken_alias_handling`, `broken_and`, `broken_scoping`, `broken_updates` → all removed from the "broken" opt-out pattern; new behavior is now the default
- `compare_time_by_ms`, `legacy_attributes`, `legacy_pluck_distinct`, `legacy_triple_equals`, `object_id_as_json_oid`, `overwrite_chained_operators` → defaults changed

**Action:** Add `config.load_defaults 7.5` to `mongoid.yml` before upgrading to explicitly preserve 7.x behavior, then migrate incrementally.

### BigDecimal / Decimal128
- Mongoid 8 introduces `map_big_decimal_to_decimal128` feature flag.
- `BigDecimal` fields formerly stored as `String` in MongoDB; 8.x changes this behavior.
- Workarea uses `Money` fields (via `money-rails`) backed by `BigDecimal` — **data migration risk if enabled**.

### `update_attributes` / `update_attributes!`
- `update_attributes` was deprecated in Mongoid 7.x (mirroring ActiveRecord's Rails 6.1 deprecation).
- **Removed in Mongoid 8.0**. The replacement is `update` / `update!`.
- **Workarea impact: HIGH** — found in **148 files** across models, controllers (admin and storefront).

### QueryCache
- `Mongoid::QueryCache` was kept in Mongoid 8.x but **deprecated**; replacement is `Mongo::QueryCache`.
- Methods: `Mongoid::QueryCache.clear_cache` → `Mongo::QueryCache.clear_cache`
- Middleware: `Mongoid::QueryCache::Middleware` → use `Mongo::QueryCache::Middleware` instead.

---

## Mongoid 8.x → 9.x Breaking Changes

### `Mongoid::QueryCache` Removed
- **Breaking:** The entire `Mongoid::QueryCache` module is removed in 9.0.
- Must replace with `Mongo::QueryCache` 1-for-1.
- Workarea core uses this in 3 places (see Impact section).

### `around_*` Callbacks for Embedded Documents Disabled by Default
- Mongoid 8.x allowed `around_save`, `around_create`, etc. on embedded docs.
- **Mongoid 9.0:** these callbacks are silently ignored by default; a console warning is printed.
- Re-enable via: `Mongoid.around_callbacks_for_embeds = true` (not recommended — risk of `SystemStackError`).
- Workarea uses `embeds_many` / `embeds_one` / `embedded_in` extensively. Any `around_*` callbacks on embedded models (e.g. `Order::Item`, `Payment` embeds) will stop firing.

### `store_in` Ignored on Embedded Documents
- Previously you could specify `store_in collection:` on an embedded doc; now ignored.
- Embedded docs always use parent's persistence context.

### `AttributeNotLoaded` Error Changed
- Accessing a field excluded via `.only()` or `.without()` now raises `Mongoid::Errors::AttributeNotLoaded` instead of `ActiveModel::MissingAttributeError`.
- Code rescuing `ActiveModel::MissingAttributeError` will no longer catch this.

### `touch` Behavior Change
- After `touch`, `changed?` now correctly returns `false` (was `true` in 8.x).
- Any code relying on changed-after-touch behavior will break.

### Removed Config Options in 9.0
All flags introduced as opt-in compatibility shims in 8.x are **removed**:
`:use_activesupport_time_zone`, `:broken_aggregables`, `:broken_alias_handling`, `:broken_and`,
`:broken_scoping`, `:broken_updates`, `:compare_time_by_ms`, `:legacy_attributes`,
`:legacy_pluck_distinct`, `:legacy_triple_equals`, `:object_id_as_json_oid`, `:overwrite_chained_operators`

Also: `load_defaults` versions 7.5 and prior are no longer accepted; minimum is `8.0`.

### `Object#blank_criteria?` Removed
- Previously deprecated method, now gone.
- Unlikely to affect Workarea directly but may affect plugin code.

### `Document#as_json :compact` Option Removed
- Replace with `.to_json.then { |j| JSON.parse(j).compact }` or call `.compact` on the returned Hash.

---

## Workarea-Specific Impact

### 1. What Changed Between Versions

| Version | Rails Support | Key Changes |
|---------|--------------|-------------|
| Mongoid 7.4 | Rails 6.0 | Stable, current Workarea target |
| Mongoid 8.0 | Rails 6.0+ | Config defaults changed, `update_attributes` removed, BigDecimal behavior |
| Mongoid 8.1.3 | Rails 7.0, 7.1 added | Patch fixes for embedded callbacks (MONGOID-5658) |
| Mongoid 9.0 | Rails 6.0+ | QueryCache removed, around-embedded callbacks off by default, config shims removed |

### 2. Breaking Changes That Affect Workarea

#### HIGH Priority

**`update_attributes!` usage (148 files)**
```
grep -r "update_attributes" --include="*.rb" -l . | grep -v spec | grep -v test
```
Found in controllers: `admin/`, `storefront/` — virtually every CRUD controller.
Found in models: `core/app/models/workarea/pricing/request.rb` (at minimum).
**Fix:** Mass-rename `update_attributes` → `update`, `update_attributes!` → `update!`

**`QueryCache` usage (3 files in core)**
```ruby
# core/app/queries/workarea/admin_search_query_wrapper.rb
Mongo::QueryCache.clear_cache

# core/app/models/workarea/releasable.rb
Mongo::QueryCache.uncached { ... }

# core/config/initializers/10_rack_middleware.rb
app.config.middleware.use(Mongo::QueryCache::Middleware)
```
**Fix:** Replace `Mongoid::QueryCache` with `Mongo::QueryCache` (required for Mongoid 9).

#### MEDIUM Priority

**Embedded document callbacks**
Workarea's `Order::Item`, `Payment` (embeds credit card, address, store credit), `Order::FraudDecision` are embedded. If any `around_save`, `around_create`, etc. exist on these, they will stop firing in Mongoid 9.
```bash
grep -r "around_save\|around_create\|around_update\|around_destroy" core/app/models/ --include="*.rb"
```
Must audit before 9.x upgrade.

**Configuration defaults**
Any Workarea-specific `mongoid.yml` or initializers that rely on the 7.4 defaults for the "broken_*" flags need review. Use `config.load_defaults '7.5'` as a safety net during the 8.x migration.

**BigDecimal / Money fields**
`Order::Item` uses `field :total_value, type: Money` and `field :total_price, type: Money`. These rely on `money-rails` + Mongoid type coercion. Verify `money-rails` behavior under Mongoid 8 before enabling `map_big_decimal_to_decimal128`.

#### LOW Priority

- `touch` changed-state behavior: unlikely to break business logic but worth a test scan
- `AttributeNotLoaded` error type change: search codebase for any rescue of `ActiveModel::MissingAttributeError` in Mongoid model contexts

### 3. Minimum Mongoid Version for Rails 7

- **Mongoid 8.0** supports Rails 6.0+ (not Rails 7 initially)
- **Mongoid 8.1.3** formally added Rails 7.0 and 7.1 support (released October 2023)
- **Mongoid 9.0** supports Rails 6.0+

**Minimum version for Rails 7 support: `mongoid ~> 8.1.3`**

Recommend targeting `mongoid ~> 8.1` (latest 8.x series) as the first step. This provides Rails 7.x support while avoiding the additional Mongoid 9 breaking changes.

### 4. Dual Support: 7.4 (Rails 6) + 8+ (Rails 7) — Feasible or Hard Cut?

**This is a hard cut. Dual support is not feasible for a gem/platform.**

Reasons:
- Mongoid 7.4 is incompatible with Rails 7 (dependency constraint, not just behavioral)
- `update_attributes!` exists only in 7.4, not 8.x — any API change must be unidirectional
- Mongoid 7.4 requires Rails ~> 6.x at the gemspec level; Bundler will reject a Rails 7 lockfile

**Conclusion:** The Rails 6 → 7 upgrade and the Mongoid 7.4 → 8.x upgrade must happen **together in the same release branch**. There is no clean way to ship a single gem version that supports both.

If Workarea needs to support Rails 6 clients while development proceeds on Rails 7, that requires maintaining **two separate release branches** (e.g., `v3.x` for Rails 6 / Mongoid 7.4, and `next`/`v4.x` for Rails 7 / Mongoid 8+). This is the `next` branch strategy already in use.

### 5. Plugin Ecosystem Impact

All Mongoid-dependent plugins require compatibility verification. Current constraints from `workarea-core.gemspec`:

| Gem | Constraint | Mongoid 8 Status | Risk |
|-----|-----------|-----------------|------|
| `mongoid-audit_log` | `>= 0.6.0` | Authored by @bencrouse (Workarea team). No official Mongoid 8 release as of research date. Internal gem — likely forkable. | HIGH |
| `mongoid-document_path` | `~> 0.2.0` | Authored by weblinc. Unmaintained upstream. | HIGH |
| `mongoid-tree` | `~> 2.1.0` | Community gem. Check rubygems.org for 8.x compat release. | MEDIUM |
| `mongoid-sample` | `~> 0.1.0` | Minimal gem, likely uses basic Mongoid API. | LOW |
| `mongoid-encrypted` | `~> 1.0.0` | Custom encryption field type. Uses Mongoid field internals — may break with 8.x type system changes. | HIGH |
| `kaminari-mongoid` | `~> 1.0.0` | Actively maintained. Likely has Mongoid 8 support. Verify latest version. | LOW |
| `mongoid-active_merchant` | `~> 0.2.0` | Authored by @bencrouse. Small adapter gem. May use `update_attributes`. | MEDIUM |

**Key risk:** Several plugins are authored by ex-Workarea/WebLinc engineers and hosted under `bencrouse` or `weblinc` GitHub orgs. They are unlikely to receive upstream Mongoid 8 updates and will likely need to be **forked and patched** by the modernization project.

---

## Recommended Strategy

### Phase 1: Prepare on Current Stack
1. Run the full test suite with deprecation warnings enabled to surface all `update_attributes` uses
2. Audit all `around_*` callbacks on embedded documents (order items, payment embeds, etc.)
3. Inventory all Mongoid plugin gems and check their current release history on RubyGems

### Phase 2: Upgrade to Mongoid 8.1.x (alongside Rails 7)
1. Add `config.load_defaults '7.5'` to `mongoid.yml` to preserve legacy defaults during transition
2. Update gemspec: `mongoid '~> 8.1'`
3. Mass-rename `update_attributes!` → `update!` and `update_attributes` → `update` across all 148 files
4. Change `Mongoid::QueryCache` usages to `Mongo::QueryCache` (3 files)
5. Fork and patch `mongoid-audit_log`, `mongoid-document_path`, `mongoid-encrypted`, `mongoid-active_merchant` for Mongoid 8 compatibility
6. Run test suite; address remaining failures

### Phase 3: Migrate Config Defaults
- Incrementally enable new Mongoid 8 behaviors (`config.load_defaults '8.0'`, then `'8.1'`)
- Confirm no behavioral regressions in order processing, pricing, and payment flows

### Phase 4: Evaluate Mongoid 9.x (future)
- After stabilizing on 8.x, evaluate 9.x for future Rails 8 support
- Primary additional work: finalize `Mongo::QueryCache` migration (required in 9), audit embedded `around_*` callbacks

---

## Risk Areas

| Risk | Severity | Files Affected |
|------|----------|---------------|
| `update_attributes!` removal | HIGH | 148 files |
| `Mongoid::QueryCache` deprecation/removal | MEDIUM | 3 files in core |
| Plugin gem Mongoid 8 compatibility | HIGH | 4-5 plugins likely need forking |
| BigDecimal/Money field behavior change | MEDIUM | Order items, pricing models |
| Embedded `around_*` callbacks (Mongoid 9) | MEDIUM | Embedded payment/order models |
| CI currently uses Ruby 3.2 but gemspec pins Rails 6.1 | MEDIUM | Build config inconsistency |

---

## Next Steps

1. **WA-NEW-020:** Audit embedded `around_*` callbacks — `grep -r "around_save\|around_create\|around_update" core/app/models/`
2. **WA-NEW-021:** Mass-rename `update_attributes` → `update` (can be a large mechanical PR)
3. **WA-NEW-022:** Fork and patch Mongoid 8-incompatible plugins (`mongoid-audit_log`, `mongoid-document_path`, `mongoid-encrypted`, `mongoid-active_merchant`)
4. **WA-NEW-023:** Bump `mongoid` to `~> 8.1` and `rails` to `~> 7.0` together; fix remaining test failures
5. **WA-NEW-024:** Migrate `Mongoid::QueryCache` → `Mongo::QueryCache` in 3 core files

---

*Research sources: MongoDB Mongoid 8.0 and 9.0 release notes, Mongoid upgrading guide, GitHub repos for plugin gems, local codebase grep analysis.*
