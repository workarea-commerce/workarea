# WA-VERIFY-091 — Mongoid 8 `any_of` scoping semantics

## Background

Mongoid 8 changes how repeated `Criteria#any_of` calls compose. In Mongoid 7,
chaining `.any_of` multiple times tended to expand/merge into one `$or` selector
(widening). In Mongoid 8 each `.any_of` call is preserved as a separate clause,
producing `$and[$or, $or, …]` (narrowing). The main risk areas are:

1. **Loop-based chaining** – calling `.any_of(…)` inside a loop produces ANDs of
   ORs in Mongoid 8, so results progressively narrow with each iteration rather
   than widen.
2. **Array-as-single-arg** – `any_of(array)` vs `any_of(*array)`. Mongoid 8's
   signature changed; splatting is safer across versions.

## Call sites audited (9 total)

| # | File | Pattern | Risk | Action |
|---|------|---------|------|--------|
| 1 | `admin/…/activity_view_model.rb` | Loop: `criteria = criteria.any_of(…)` per id | **High** – multiple ids would narrow to nothing | Fixed: collect all clauses, call `any_of` once |
| 2 | `core/…/tax/rate.rb` | `any_of(clauses)` – array as single arg | Low–Med | Fixed: splatted to `any_of(*clauses)` |
| 3 | `core/…/discount/generated_promo_code.rb` | `any_of({ expires_at: nil }, { :expires_at.gt => … })` | Low – single call, two hashes | OK – no change needed; behavior confirmed by new test |
| 4 | `core/…/taxonomy_sitemap.rb` | `.any_of({ :url.ne => nil }, { :navigable_id.ne => nil })` | Low – single standalone call | OK – existing test passes |
| 5 | `core/…/navigation/redirect.rb` | `any_of({ path: regex }, { destination: regex })` | Low – single standalone call | OK – covered by new test |
| 6 | `core/…/featured_products.rb` | `Release::Changeset.any_of(…)` | Low – single standalone call | OK – covered by new test |
| 7 | `core/…/tax/category.rb` | `rates.any_of(…)` | Low – single standalone call | OK – existing test passes |
| 8 | `core/lib/…/products_missing_variants.rb` | `.any_of({ variants: nil }, { variants: [] })` | Low – single call | OK – test expanded to cover both `nil` and `[]` cases |
| 9 | `core/lib/…/products_missing_images.rb` | `.any_of({ images: nil }, { images: [] })` | Low – single call | OK – test expanded to cover both `nil` and `[]` cases |

## Changes made

### `admin/app/view_models/workarea/admin/activity_view_model.rb`

**Problem:** The `scoped_entries` method iterated over `options[:id]` and chained
`criteria.any_of(…)` inside the loop. With Mongoid 8 this would produce an AND of
ORs, returning empty results when more than one id was supplied.

**Fix:** Collect all `{ audited_id: … }` and `{ 'document_path.id' => … }` clauses
into a flat array and call `.any_of(*clauses)` once outside the loop.

### `core/app/models/workarea/tax/rate.rb`

**Problem:** `any_of(clauses)` — passing an Array as a single argument. Mongoid 8
signature prefers splatted args.

**Fix:** Changed to `any_of(*clauses)`.

## Tests added / updated

- `core/test/lib/workarea/lint/products_missing_variants_test.rb` — cover both
  `variants: []` and `variants: nil` cases.
- `core/test/lib/workarea/lint/products_missing_images_test.rb` — same for images.
- `core/test/models/workarea/pricing/discount/generated_promo_code_test.rb` —
  `test_not_expired_scope`: confirms both `nil` and future-date codes are returned,
  expired codes are excluded.
- `core/test/models/workarea/navigation/redirect_test.rb` — `test_search`: both
  path and destination regex branches return expected records.
- `core/test/models/workarea/tax/rate_test.rb` — `test_search`: region, postal
  code, and country clause branches all return expected records.
- `core/test/models/workarea/featured_products_changesets_test.rb` —
  `test_changesets_finds_by_product_id_in_changeset_and_original`.

## No intentional behavior differences

All changes are backward-compatible and preserve the original Mongoid 7 semantics.
