# Mongoid 8 `any_of` Semantics Change

## Background

Mongoid 8 changed how `Criteria#any_of` composes and how it accepts arguments.
Applications upgrading from Mongoid 7 may silently return **empty result sets** or
**incorrect data** without any runtime errors if they hit either of the two affected
patterns.

**Reference implementation:** [PR #1091](https://github.com/workarea-commerce/workarea/pull/1091)
**Issue:** [#1129](https://github.com/workarea-commerce/workarea/issues/1129)

---

## The Two Breaking Patterns

### Pattern 1 — Array as single argument (low–medium risk)

**Mongoid 7** accepted an Array as a single argument:

```ruby
clauses = [{ region: regex }, { postal_code: regex }]
any_of(clauses)   # worked in Mongoid 7
```

**Mongoid 8** changed the signature to prefer splatted arguments. Passing an Array
directly may not behave as expected.

**Fix:** Splat the array:

```ruby
clauses = [{ region: regex }, { postal_code: regex }]
any_of(*clauses)  # safe across Mongoid 7 and 8
```

**Real example from Workarea (PR #1091):**
`core/app/models/workarea/tax/rate.rb` → `self.search`

---

### Pattern 2 — Loop-based chaining (high risk)

**Mongoid 7** tended to merge repeated `.any_of` calls into a single `$or`
selector (widening). **Mongoid 8** preserves each call as a distinct clause,
producing `$and[$or, $or, …]` (narrowing). The result:

- With **one** item in the loop → works fine (same behaviour).
- With **two or more** items → progressively narrows; likely returns empty set.

```ruby
# ❌ BROKEN in Mongoid 8 — produces $and[$or, $or, …]
criteria = Model.all
ids.each do |id|
  criteria = criteria.any_of({ field_a: id }, { field_b: id })
end
```

**Fix:** Collect all clauses first, then call `any_of` once:

```ruby
# ✅ Correct — produces a single $or with all clauses
clauses = ids.flat_map do |id|
  [{ field_a: id }, { field_b: id }]
end
criteria = criteria.any_of(*clauses)
```

**Real example from Workarea (PR #1091):**
`admin/app/view_models/workarea/admin/activity_view_model.rb` → `scoped_entries`

---

## Detection

Find all `any_of` call sites in the codebase:

```bash
# With ripgrep (recommended)
rg "\.any_of" --glob='*.rb'

# With grep
grep -r '\.any_of' . --include='*.rb'
```

For each match, check:
1. Is the argument a plain `Array` variable (not splatted)? → apply **Pattern 1 fix**.
2. Is the call inside a loop (`each`, `map`, `times`, `while`, etc.)? → apply **Pattern 2 fix**.

---

## Quick Reference

| Symptom | Likely cause | Fix |
|---------|-------------|-----|
| Correct results with 1 record, empty with 2+ | Loop-based chaining | Collect clauses, single `any_of(*clauses)` |
| Unexpected empty or incorrect results from array-arg call | Array as single arg | Splat the arg: `any_of(*clauses)` |

---

## Audit Checklist

When auditing `any_of` call sites, classify each as:

- **OK** — Single standalone call with two or more inline hash arguments. No change needed; behavior is identical across versions.
- **Low risk** — `any_of(array_var)` pattern. Splat the variable.
- **High risk** — `any_of(…)` inside a loop. Refactor to collect-then-splat.

---

## No Intentional Behavior Differences

The fixes above preserve the original Mongoid 7 semantics — they do **not** change
query logic; they only make the Mongoid 8 query generation match the intended `$or`
behavior.

---

## Related Docs

- [Mongoid 8 Embedded Document Migration](../mongoid-8-embedded-document-migration.md)
