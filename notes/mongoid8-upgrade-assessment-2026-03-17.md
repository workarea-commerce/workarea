# Mongoid 8 Upgrade Assessment

**Issue:** #1069 — WA-VERIFY-083  
**Date:** 2026-03-17  
**Scope:** `workarea-core` only (plugins assessed separately)  
**Motivation:** Mongoid 8.x is required for Rails 7.1+ compatibility. Mongoid 7.x's
dependency on `activesupport ~> 6.x` blocks Rails 7.1 upgrade.

---

## Executive Summary

The Mongoid 7 → 8 upgrade is **medium-complexity**. The bulk of the work is
replacing `Mongoid::QueryCache` references (removed in Mongoid 8) and auditing
`belongs_to` optional semantics. Third-party gem compatibility is largely fine
with one notable risk (`mongoid-document_path` version constraint). No data
migrations are required. The **incremental approach** is recommended.

---

## Breaking Changes by Severity

### HIGH — Must fix before Mongoid 8 can boot

#### 1. `Mongoid::QueryCache` removed (→ `Mongo::QueryCache`)

Mongoid 8 removes `Mongoid::QueryCache` entirely. Callers must use
`Mongo::QueryCache` instead.

**Affected files (3 call sites):**

| File | Line | Change needed |
|------|------|---------------|
| `core/app/queries/workarea/admin_search_query_wrapper.rb` | 41 | `Mongoid::QueryCache.clear_cache` → `Mongo::QueryCache.clear` |
| `core/app/models/workarea/releasable.rb` | 78 | `Mongoid::QueryCache.uncached` → `Mongo::QueryCache.uncached` |
| `core/config/initializers/10_rack_middleware.rb` | 5 | `Mongoid::QueryCache::Middleware` → `Mongo::QueryCache::Middleware` |

The initializer comment already notes this is a Mongoid 7.x-specific pattern
(`# Mongoid::QueryCache::Middleware exists in Mongoid 7.x`), so this was
anticipated.

**Estimated effort:** 30 min — mechanical search-and-replace.

---

#### 2. `belongs_to` required by default changed

Mongoid 7 introduced `belongs_to` required-by-default via a feature flag
(`belongs_to_required_by_default`). Mongoid 8 makes this the unconditional
default — documents with a `belongs_to` that lacks `optional: true` will
raise a validation error if the foreign key is nil.

**Affected files — 18 `belongs_to` without `optional: true`:**

```
core/app/models/workarea/payment/processing.rb:13
core/app/models/workarea/payment/transaction.rb:16
core/app/models/workarea/payment/transaction.rb:21
core/app/models/workarea/payment/saved_credit_card.rb:13
core/app/models/workarea/catalog/product.rb:46        (copied_from)
core/app/models/workarea/navigation/menu.rb:13        (taxon)
core/app/models/workarea/navigation/taxon.rb:21       (parent)
core/app/models/workarea/navigation/taxon.rb:29       (navigable)
core/app/models/workarea/tax/rate.rb:31               (category)
core/app/models/workarea/content/page.rb:18           (copied_from)
core/app/models/workarea/user/password_reset.rb:9     (user)
core/app/models/workarea/user/recent_password.rb:10   (user)
core/app/models/workarea/user/admin_bookmark.rb:11    (user)
core/app/models/workarea/release/changeset.rb:17      (release)
core/app/models/workarea/order.rb:64                  (copied_from)
core/app/models/workarea/comment.rb:12                (commentable)
core/app/models/workarea/pricing/discount/redemption.rb:20   (discount)
core/app/models/workarea/pricing/discount/generated_promo_code.rb:31 (code_list)
```

Most of these are semantically optional (e.g., `copied_from`, polymorphic
associations, soft-delete patterns). Each must be evaluated individually:

- Associations that are truly required (e.g., `user` on `password_reset`) may
  already behave correctly and just need `optional: false` made explicit.
- Associations that are nullable (e.g., `copied_from`) need `optional: true`.
- Polymorphic associations (`navigable`, `commentable`, `releasable`) are
  typically nullable and need `optional: true`.

**Estimated effort:** 2–3 hours (review each association, add `optional:` annotation).

---

### MEDIUM — Behavioral changes that require validation

#### 3. `any_of` query operator semantics

Mongoid 8 changes `any_of` to use `$or` correctly when chained with other
scopes. Mongoid 7 had a known bug (`broken_and` config flag) where chaining
`any_of` after other criteria could silently drop conditions.

**Affected (8 call sites):**

```
core/app/queries/workarea/taxonomy_sitemap.rb:24
core/app/models/workarea/featured_products.rb:16
core/app/models/workarea/navigation/redirect.rb:31
core/app/models/workarea/tax/category.rb:37
core/app/models/workarea/tax/rate.rb:45
core/app/models/workarea/pricing/discount/generated_promo_code.rb:47
core/lib/workarea/lint/products_missing_images.rb:6
core/lib/workarea/lint/products_missing_variants.rb:6
```

These should be tested after upgrade to ensure queries return expected results.
The fix (if needed) is typically wrapping in explicit `or` logic.

**Estimated effort:** 1–2 hours (test coverage review + manual verification).

#### 4. `pluck` behavior changes

Mongoid 8 changes `pluck` to return an array of scalars (not arrays) when a
single field is specified, and correctly handles distinct behavior. The
`legacy_pluck_distinct` config flag from Mongoid 7 is removed.

**Affected (13 call sites):**

```
core/app/queries/workarea/find_unique_slug.rb:30
core/app/queries/workarea/order_cancellation_metrics.rb:71
core/app/queries/workarea/order_metrics.rb:105
core/app/queries/workarea/alerts.rb:98
core/app/models/workarea/search/customization.rb:28
core/app/seeds/workarea/orders_seeds.rb:114
core/app/seeds/workarea/insights_seeds.rb:20, 28
core/app/workers/workarea/bulk_index_products.rb:10
core/app/workers/workarea/bulk_index_searches.rb:8
core/lib/workarea/tasks/migrate.rb:96
```

Most current usage is single-field `pluck(:id)` or `pluck(:slug)` which
should work correctly in Mongoid 8. Review for any multi-field pluck calls.

**Estimated effort:** 30 min review + test run.

#### 5. `find_or_create_by` thread-safety / upsert semantics

Mongoid 8 changes the underlying upsert behavior slightly. The 5 call sites
using `find_or_create_by` should be smoke-tested for correct behavior,
especially `Metrics::User` which is used in high-concurrency import contexts.

**Affected (5 call sites):**

```
core/app/models/workarea/metrics/user.rb:53
core/app/models/workarea/content.rb:43, 45
core/app/models/workarea/search/settings.rb:25
core/app/models/workarea/pricing/discount/free_gift.rb:85
```

**Estimated effort:** 30 min.

---

### LOW — Config / gem constraint updates

#### 6. `Mongoid::Config.load_defaults` version support

Mongoid 8 drops `load_defaults` for versions `< 7.0`. Workarea's dummy app
currently uses `config.load_defaults 6.1` (Rails), not Mongoid's
`load_defaults`. Mongoid configuration uses
`Mongoid::Config.load_configuration(...)` directly (no `load_defaults` call),
so **no action needed here** beyond verifying behavior with the new defaults.

#### 7. `Mongoid::Config` new defaults in Mongoid 8

Mongoid 8 enables several previously-opt-in behaviors by default:
- `broken_and: false` (fixed `any_of` scoping — see item #3 above)
- `broken_scoping: false` (stricter scope chaining)
- `broken_updates: false` (atomic update corrections)
- `compare_time_by_ms: true` (time comparison includes milliseconds)
- `legacy_attributes: false` (attribute handling)

These are the flags previously toggled via `config.load_defaults`. Workarea
does not call `Mongoid::Config.load_defaults`, so it currently uses Mongoid 7
defaults. After upgrading to Mongoid 8, all flags default to the new behavior.

**Action:** After gemspec bump, run full test suite to identify any behavioral
regressions from the new defaults.

---

## Third-Party Gem Compatibility Matrix

| Gem | Current Version | Mongoid Constraint | Mongoid 8 Compatible? | Notes |
|-----|----------------|-------------------|----------------------|-------|
| `mongoid-audit_log` | 0.6.1 | `>= 7.0` | ⚠️ Likely yes, needs test | Field type Symbol deprecation already patched in workarea |
| `mongoid-document_path` | 0.2.0 | `>= 7.0` | ⚠️ Constrained to `>= 7.0` only | May need fork or version bump if Mongoid 8 API changed |
| `mongoid-tree` | 2.1.1 / 2.3.0 | `>= 4.0, < 10` | ✅ Yes | Supports up to Mongoid 9 |
| `mongoid-sample` | 0.1.0 | `>= 4.0` | ✅ Likely yes | Simple aggregation wrapper |
| `mongoid-encrypted` | 1.0.0 | `>= 6.4.0` | ✅ Likely yes | Workarea-owned gem |
| `kaminari-mongoid` | 1.0.2 | `>= 0` | ✅ Yes | No version pin on Mongoid |
| `mongoid-active_merchant` | 0.2.3 | `>= 4.0.0` | ✅ Likely yes | Simple field type serializers |

**Key risk:** `mongoid-document_path` only declares `>= 7.0` — needs testing
with Mongoid 8 to confirm internal API usage hasn't changed. This gem is
Workarea-owned (weblinc/mongoid-document_path) so a patch release is feasible.

---

## Custom Mongoid Extensions Impact

Workarea defines several Mongoid monkey-patches in
`core/lib/workarea/ext/mongoid/`. Each needs review:

| File | Risk | Notes |
|------|------|-------|
| `each_by.rb` | LOW | Uses `Mongoid::Criteria` public API only |
| `embedded_children.rb` | MEDIUM | Uses `embedded_relations` — verify still present in Mongoid 8 |
| `error.rb` | LOW | Adds `as_json`/`to_json` to `MongoidError` |
| `except.rb` | LOW | Simple `.where(:id.ne => id)` — stable API |
| `find_ordered.rb` | LOW | Uses `any_in` — verify still works |
| `list_field.rb` | LOW | Pure Ruby, no Mongoid internals |
| `lookup_hash.rb` | MEDIUM | Calls `fields['_id'].type.mongoize` — verify field introspection API |
| `time_demongoize_string.rb` | LOW | Prepends onto `Time` singleton — likely stable |
| `timestamps_timeless.rb` | MEDIUM | Patches `Mongoid::Timestamps` internals — verify against Mongoid 8 |
| `audit_log_entry.rb` | LOW | Already patched for BSON Symbol deprecation (WA-NEW-010) |

---

## `mongoid-compatibility` Gem

The `mongoid-compatibility` gem provides shims for cross-version Mongoid
support (used by `mongoid-tree` as a dev dependency). It is **not needed** as
a runtime dependency for workarea-core. The `mongoid-tree` gem uses it only
in development/test context for its own specs. No action needed.

---

## Recommended Approach

### Incremental (Recommended)

1. **Phase 1 — Gemspec bump + boot** (~1 day)
   - Change `core/workarea-core.gemspec`: `~> 7.4` → `~> 8.0`
   - Run `bundle update mongoid` and ensure app boots
   - Fix `Mongoid::QueryCache` → `Mongo::QueryCache` (3 files, HIGH #1)

2. **Phase 2 — belongs_to audit** (~1 day)
   - Review all 18 `belongs_to` declarations
   - Add `optional: true` where the FK is nullable
   - Add explicit `optional: false` where truly required
   - Run test suite; fix validation failures

3. **Phase 3 — Query behavior verification** (~1 day)
   - Run full test suite against Mongoid 8 defaults
   - Spot-check `any_of` queries for correctness
   - Verify `pluck` results unchanged
   - Verify `find_or_create_by` under concurrent test scenarios

4. **Phase 4 — Gem compatibility testing** (~half day)
   - Verify `mongoid-document_path` with Mongoid 8
   - Verify `mongoid-audit_log` with Mongoid 8
   - Open patch PRs on Workarea-owned gems if needed

### Why Not Big-Bang?

A big-bang upgrade risks surfacing many silent behavioral changes at once
(especially around `any_of` scoping and `belongs_to` validation). The
incremental approach lets each class of issue be isolated, tested, and fixed
independently with clear rollback points.

---

## Estimated Total Effort

| Phase | Effort |
|-------|--------|
| Phase 1: QueryCache + boot | ~4 hours |
| Phase 2: belongs_to audit | ~6 hours |
| Phase 3: Query verification | ~4 hours |
| Phase 4: Gem compat testing | ~3 hours |
| **Total** | **~17 hours (~2 days)** |

---

## Related Issues / Context

- This assessment is prerequisite to the Rails 7.1 upgrade track
- `mongoid-encrypted` is Workarea-owned — easy to patch if needed
- BSON Symbol deprecation already addressed in WA-NEW-010 (audit_log patch)
- No data migrations required — Mongoid 8 is schema-compatible with Mongoid 7
  for the document structures used in workarea-core

---

*Assessment generated by automated audit of `workarea-core` on `next` branch.*
