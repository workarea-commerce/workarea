# WA-VERIFY-089 / #1080 - Embedded association `.count` (Mongoid 8)

Mongoid 8 changed embedded association `.count` to always hit the database.
This can introduce unnecessary queries (and N+1s) when the embedded documents
are already loaded in memory.

## Changes

Replaced embedded-association `.count` calls with `.size`:

- `core/app/seeds/workarea/orders_seeds.rb`
  - `user.addresses.count` → `user.addresses.size`
- `admin/app/views/workarea/admin/catalog_categories/index.html.haml`
  - `result.product_rules.count` → `result.product_rules.size`
- `admin/app/views/workarea/admin/catalog_variants/index.html.haml`
  - `@variants.count` → `@variants.size`

Also updated tests and docs that were using embedded-association `.count` to avoid
recommending/depending on database-backed counts for embedded documents:

- `core/test/models/workarea/order_test.rb` — `order.items.count` → `.size`
- `core/test/services/workarea/add_multiple_cart_items/item_test.rb` — `order.items.count` → `.size`
- `core/test/services/workarea/add_multiple_cart_items_test.rb` — `order.items.count` → `.size`
- `core/test/services/workarea/cart_cleaner_test.rb` — `@order.items.count` → `.size`
- `core/test/services/workarea/create_fulfillment_test.rb` — `fulfillment.items.count` → `.size`
- `core/test/services/workarea/inventory_adjustment_test.rb` — `order.items.count` → `.size`
- `core/test/services/workarea/order_merge_test.rb` — `original.items.count` → `.size`

## Intentionally unchanged

- `.count` calls on Mongoid criteria/relations (non-embedded) where a database
  count is expected.
- `.count` on Ruby collections where it is purely in-memory (e.g. arrays/hashes,
  or `Enumerable#count { ... }`).
