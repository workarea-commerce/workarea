# WA-017 Review: ES 7.x mapping type removal (core)

**Commit:** 6b849fb3

## Verdict: CHANGES_REQUESTED

This is the right direction and appears to remove the ES mapping-type wrappers correctly, but the change set as committed does **not** pass `bundle exec rake core_test` and there are a few correctness issues introduced by the ES 7.x query updates.

## What I reviewed

- Implementer notes: `notes/WA-017.md`
- Diff for the 9 core files listed in the WA
- Ran `bundle exec rake core_test` (aborted after multiple failures)
- Grep for remaining `"_doc"` usage under `core/`

## Diff review (9 files)

### 1) `core/lib/workarea/configuration.rb` (mappings)
- ✅ Mapping-type wrappers removed (no more `admin: { ... }`, `help: { ... }`, `order: { ... }` wrappers, and storefront consolidated).
- ✅ Deprecated field types updated:
  - `string` → `text`/`keyword`
  - `index: 'not_analyzed'` removed in favor of `keyword`
  - `analyzer: 'keyword'` removed from keyword dynamic template
- ✅ Storefront mapping consolidation looks reasonable; `query` percolator moved into main `properties`.
- ⚠️ Please double-check whether adding `release_id` / `changeset_release_ids` at the root is sufficient for all category-query/percolator use cases (seems intended per notes).

### 2) `core/lib/workarea/elasticsearch/document.rb` (document operations)
- ✅ All operations now force `type: '_doc'`.
- ⚠️ This is correct for ES 7.x with a legacy client, but it does mean callers/tests that previously depended on multiple types within one index need to be rethought/updated.

### 3) `core/lib/workarea/elasticsearch/index.rb` and
### 4) `core/app/queries/workarea/search/query.rb` (total hits)
- ✅ Total count handling updated to accept both integer and `{ value: N, relation: ... }` formats.

### 5) `core/app/models/workarea/search/storefront/category_query.rb`
- ✅ Direct index operations now use `type: '_doc'`.

### 6) `core/app/queries/workarea/search/related_products.rb` and
### 7) `core/app/queries/workarea/search/related_help.rb` (MLT)
- ✅ Updated from `ids` + `like_text` to `like: [...]` (ES 7.x compatible shape).
- ❌ **Bug:** Both implementations can generate a `more_like_this` query where `like` is empty.
  - ES 7.x rejects this with: `more_like_this requires 'like' to be specified`.
  - This showed up during `core_test` via `Workarea::SendRefundEmailTest#test_perform`.
  - Fix suggestion: if there are no ids and no like_text, return a safe query (`match_none`) or skip the MLT clause entirely.

### 8) `core/app/queries/workarea/search/product_search.rb`
- ✅ `minimum_number_should_match` → `minimum_should_match`.

### 9) `core/test/lib/workarea/elasticsearch/document_test.rb`
- ✅ Test mapping wrapper removed.
- ❌ **Incorrect update:** `test_count` previously asserted that counts differed by type (`foo` vs `bar`). With mapping types removed, both calls now pass `type: '_doc'` but the expectations were left as `1` and `0`:
  - 
  ```ruby
  assert_equal(1, Foo.current_index.count({}, type: '_doc'))
  assert_equal(0, Foo.current_index.count({}, type: '_doc'))
  ```
  - This assertion cannot be valid (same query, same type).
  - The test should be rewritten to validate something meaningful post-types (e.g., count by index, by query filter, or remove the “different type” expectation).

## Test results

`bundle exec rake core_test` **FAILED** quickly with multiple failures/errors. The first several included:

- **Failure:** `Workarea::Insights::PopularSearchesTest#test_results` expected `2`, actual `1`.
- **Error:** `Workarea::Search::AdminDiscountsTest#test_sort` ES 400: `query malformed, empty clause found` under a `bool.must` (suggests some query builder is producing an empty clause/array that ES 7.x is stricter about).
- **Error:** `Workarea::SendRefundEmailTest#test_perform` ES 400: `more_like_this requires 'like' to be specified` (tied directly to the MLT change noted above).

Given the WA’s requirement that all **1543** core tests pass, this commit is not in an acceptable state.

## `_doc` grep

`grep -rn '"_doc"' core/` surfaced matches in `core/test/dummy/log/test.log` (logged ES responses). Excluding logs, there were no remaining matches in `core/`.

## Requested changes

1. **Fix MLT queries** (`related_products`, `related_help`) to never emit `more_like_this` with an empty `like` array.
2. **Fix/replace `DocumentTest#test_count`** (and any similar tests) that relied on mapping types.
3. Investigate and fix the **empty bool clause** ES 7.x error (`AdminDiscountsTest#test_sort`). Likely a `.compact`/presence guard is needed when constructing `must`/`filter` arrays.
4. Re-run `bundle exec rake core_test` and ensure all tests pass.

---

If these issues are resolved, the mapping wrapper removal + total hits compatibility approach looks solid.
