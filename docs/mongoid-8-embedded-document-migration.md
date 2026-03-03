# Mongoid 8: Embedded Document Touch Behavior — Migration Notes

**Issue:** [#716](https://github.com/workarea-commerce/workarea/issues/716)
**PR:** [#738](https://github.com/workarea-commerce/workarea/pull/738)
**Fixed in:** wa-new-038-mongoid-embedded

---

## Breaking Change in Mongoid 8

Mongoid 8 changed the **default `touch` behavior** for `embedded_in` associations.

| Mongoid Version | Default | Effect |
|----------------|---------|--------|
| Mongoid 7.x | `touch: false` | Saving an embedded document does **not** automatically update `updated_at` on the parent |
| Mongoid 8.x | `touch: true` | Saving an embedded document **automatically** updates `updated_at` on the parent |

This is a silent behavioral change. Without explicit `touch: false` declarations, upgrading to Mongoid 8 causes all embedded document saves to cascade a touch to the parent, potentially causing:

- Unexpected cache invalidation (fragment caches, CDN caches keyed on `updated_at`)
- Additional write operations on parent documents
- Changed document ordering (if sorted by `updated_at`)
- Performance degradation on high-write paths

---

## What Was Audited

All 40 embedded document relationships in `core/app/models/workarea/` were cataloged:

### `embeds_many` / `embeds_one` (parent side)

| Parent Model | Embedded Association | Class |
|-------------|---------------------|-------|
| `Order` | `embeds_many :items` | `Order::Item` |
| `Order` | `embeds_one :traffic_referrer` | |
| `Order` | `embeds_one :fraud_decision` | `Order::FraudDecision` |
| `Order::Item` | `embeds_many :price_adjustments` | `PriceAdjustment` |
| `Metrics::User` | `embeds_one :viewed` | `Metrics::Affinity` |
| `Metrics::User` | `embeds_one :purchased` | `Metrics::Affinity` |
| `Segment` | `embeds_many :rules` | `Segment::Rules::Base` |
| `Payment` | `embeds_one :address` | |
| `Payment` | `embeds_one :credit_card` | |
| `Payment` | `embeds_one :store_credit` | |
| `Catalog::Product` | `embeds_many :variants` | `Catalog::Variant` |
| `Catalog::Product` | `embeds_many :images` | `Catalog::ProductImage` |
| `Shipping` | `embeds_one :address` | |
| `Shipping` | `embeds_one :shipping_service` | |
| `Shipping` | `embeds_many :price_adjustments` | |
| `Shipping::Service` | `embeds_many :rates` | `Shipping::Rate` |
| `Fulfillment` | `embeds_many :items` | `Fulfillment::Item` |
| `Fulfillment::Item` | `embeds_many :events` | `Fulfillment::Event` |
| `Content` | `embeds_many :blocks` | `Content::Block` |
| `User` (addresses) | `embeds_many :addresses` | |
| `Release::Changeset` | `embeds_many :document_path` | `Mongoid::DocumentPath::Node` |
| `ProductList` | `embeds_many :product_rules` | `ProductRule` |
| `Fulfillment` | `embeds_many :items` | `Fulfillment::Item` |
| `Inventory::Transaction` | `embeds_many :items` | `Inventory::TransactionItem` |
| `Pricing::Sku` | `embeds_many :prices` | `Pricing::Price` |

### `embedded_in` (child side) — touch decisions

| Child Model | Parent | touch: setting | Rationale |
|------------|--------|---------------|-----------|
| `Order::Item` | `Order` | `false` | Order timestamp not affected by item updates |
| `Order::FraudDecision` | `Order` | `false` | Fraud decisions don't need to cache-bust order |
| `Metrics::Affinity` | `Metrics::User` | `false` | High-frequency writes; parent touch unnecessary |
| `Payment::Tender` | `Payment` | `false` | Tender updates don't need to propagate to payment |
| `Catalog::Variant` | `Catalog::Product` | `true` ✓ | Variant changes should invalidate product caches |
| `Catalog::ProductImage` | `Catalog::Product` | `false` + callbacks | Explicit `after_save`/`after_destroy` handle touching |
| `Segment::Rules::Base` | `Segment` | `false` | Rule updates handled by segment's own logic |
| `Shipping::Rate` | `Shipping::Service` | `false` | Rate updates don't need to cascade |
| `Shipping::ServiceSelection` | `Shipping` | `false` | Service selections managed independently |
| `Content::Block` | `Content` | `false` | Block edits handled via release/changeset system |
| `Fulfillment::Item` | `Fulfillment` | `false` | High-frequency status updates |
| `Fulfillment::Event` | `Fulfillment::Item` | `false` | Event append-only; no cache value |
| `ProductRule` | `ProductList` | `false` | Rules drive regen; parent touch not needed |
| `Address` | `addressable` | `false` | Polymorphic; address updates don't need to propagate |
| `Pricing::Price` | `Pricing::Sku` | `true` ✓ | Price changes must invalidate SKU pricing cache |
| `Inventory::TransactionItem` | `Inventory::Transaction` | `false` | Append-only ledger items |

---

## What Changed in This PR

All `embedded_in` associations without an explicit `touch:` option were updated to include `touch: false`. This makes the Mongoid 7 default behavior **explicit** so it is **preserved** when upgrading to Mongoid 8.

`Catalog::ProductImage` was updated to use `touch: false` in `embedded_in` (instead of `touch: true`) while keeping the existing explicit `after_save`/`after_destroy` callbacks. This avoids double-touching the parent product in Mongoid 8.

---

## Client Impact

**No action required for existing client deployments.** This change makes implicit defaults explicit; the runtime behavior of touch cascading is identical between Mongoid 7 and Mongoid 8 after applying this patch.

### For clients with custom plugins

If you have plugins or extensions with `embedded_in` associations, you should audit them before upgrading to Mongoid 8:

```ruby
# Before (Mongoid 7 default: touch: false — safe)
embedded_in :order

# After Mongoid 8 upgrade without explicit declaration: touch: true (BREAKING)
# Fix: add explicit touch: false to preserve old behavior
embedded_in :order, touch: false
```

Run this to find undeclared `embedded_in` in your plugins:

```bash
grep -rn "embedded_in" app/models/ --include="*.rb" | grep -v "touch:"
```

Any hits are candidates for explicit `touch: false` declaration.

---

## References

- [Mongoid 8 Release Notes — Touch behavior change](https://www.mongodb.com/docs/mongoid/current/release-notes/mongoid-8.0/)
- [GitHub Issue #716](https://github.com/workarea-commerce/workarea/issues/716)
- [PR #738](https://github.com/workarea-commerce/workarea/pull/738)
