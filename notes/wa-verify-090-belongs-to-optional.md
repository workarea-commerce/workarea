# WA-VERIFY-090 / Issue #1082

## Goal
Mongoid 8 is expected to treat `belongs_to` as **required by default**.

Workarea (Mongoid 7) has historically behaved as if `belongs_to` is **optional by default** unless the model explicitly validates presence.

To prevent Mongoid 8 upgrading from introducing surprise validation failures, we are making `optional:` explicit on all `belongs_to` associations in `workarea-core`.

## Approach
- For associations that already had `optional:` set, leave as-is.
- For associations that did **not** already declare `optional:`, default to **`optional: true`** to preserve current Mongoid 7 behavior.
- We did **not** change any business rules by making associations required (i.e. we avoided adding `optional: false`) unless there was already an explicit presence requirement.

## Associations updated (added `optional: true`)
- `Workarea::Payment::SavedCreditCard` → `belongs_to :profile`
- `Workarea::Pricing::Discount::GeneratedPromoCode` → `belongs_to :code_list`
- `Workarea::Tax::Rate` → `belongs_to :category`
- `Workarea::Release::Changeset` → `belongs_to :release`
- `Workarea::Payment::Transaction` → `belongs_to :payment`
- `Workarea::Comment` → `belongs_to :commentable` (polymorphic)
- `Workarea::Pricing::Discount::Redemption` → `belongs_to :discount`
- `Workarea::User::AdminBookmark` → `belongs_to :user`
- `Workarea::User::RecentPassword` → `belongs_to :user`
- `Workarea::User::PasswordReset` → `belongs_to :user`
- `Workarea::Payment::Processing` → `belongs_to :payment`
- `Workarea::Navigation::Menu` → `belongs_to :taxon`

## Ambiguities / follow-ups
Several of the above relationships are *semantically* required in normal operation (e.g. transactions always have a payment), but Workarea did not previously enforce presence at the model layer. This change intentionally keeps that behavior stable.

If we later want stricter data integrity, that should be a separate change with explicit validation/test coverage (and likely a migration/cleanup step for any historical data).
