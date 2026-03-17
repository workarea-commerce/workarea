# WA-VERIFY-093 — Mongoid 8: `find_or_create_by` / upsert semantics

## Summary
Mongoid 8 can surface duplicate-key errors more readily when `find_or_create_by` races under concurrency.

Workarea core has 5 call sites relying on idempotent “get-or-create” behavior:

- `Workarea::Metrics::User.save_order` (`_id` = email)
- `Workarea::Search::Settings.current` (`index`)
- `Workarea::Content.for(String)` (system content by `name`)
- `Workarea::Content.for(contentable)` (by `contentable_type` + `contentable_id`)
- `Workarea::Pricing::Discount::FreeGift#apply` (`Pricing::Sku` by `_id`)

## Changes
### Enforce uniqueness where required
- `Workarea::Search::Settings`
  - Added unique index on `index`

- `Workarea::Content`
  - Added unique + sparse index on `name` (system content)
  - Added unique + sparse compound index on `contentable_type/contentable_id` (contentable content)

> `sparse: true` avoids applying the unique constraint to documents that do not persist those fields (Mongoid omits nil fields).

### Be resilient to duplicate-key races
- `Search::Settings.current` and `Content.for` now rescue duplicate key errors (`E11000`) and fall back to `find_by`.

This preserves public behavior while preventing intermittent errors during concurrent first-write scenarios.

## Tests
Added/extended tests asserting idempotency for:
- `Search::Settings.current`
- `Content.for` (string + contentable)
- `Pricing::Discount::FreeGift#apply` (does not create extra `Pricing::Sku` records)
