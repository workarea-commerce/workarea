# BigDecimal / Money Serialization (Rails 7)

Rails 7 changes how `BigDecimal` values are serialized to JSON and YAML, and
how Mongoid maps numeric types. Workarea relies heavily on `BigDecimal` and the
`Money` value object (via `workarea-core`'s `Workarea::Money`) for prices,
totals, and discount amounts. Applications that do not account for these changes
can silently corrupt monetary data or raise runtime type errors after upgrading.

---

## Symptom

One or more of the following surface after upgrading to Rails 7 (or after
bumping `activerecord`/`activesupport` to 7.x):

- `BigDecimal` values round-trip through JSON as plain `Float` strings instead
  of `"BigDecimal"` wrapped strings, causing precision loss on prices/totals.
- `ArgumentError: wrong number of arguments (given 1, expected 0)` when calling
  `Money.new` or `BigDecimal()` from serialized cache or session data written
  under Rails 6.
- `TypeError: no implicit conversion of BigDecimal into String` in serializers
  or API responses.
- Checkout order totals (e.g. `Workarea::Order#total_price`) differ slightly
  from the database-persisted value — typically a floating-point drift of
  `±0.000000001`.
- Mongoid fields typed as `BigDecimal` begin returning `Float` in logs/specs
  after enabling `config.active_support.use_msgpack_serializer` or
  `config.cache_store = :redis_cache_store`.

---

## Root Cause

### 1. `BigDecimal` → JSON encoding changed in Rails 7

Rails 7 (specifically `activesupport` ≥ 7.0) removed the monkey-patch that
made `BigDecimal#as_json` return a special `{ "$bigdecimal": "..." }` wrapper.
Instead, `BigDecimal#to_s` is called, which produces a plain decimal string
(`"9.99"`) or scientific notation (`"1.0E+2"`). When that string is read back,
nothing automatically promotes it to `BigDecimal`, so it is kept as `String` or
parsed as `Float`.

### 2. `BigDecimal()` kernel method signature tightened

Ruby 3.1+ (bundled with Rails 7 stacks) deprecated the zero-argument form
`BigDecimal()` and calling `BigDecimal.new`. Any cached/serialized payload that
stores constructor metadata from older gems may fail to deserialize.

### 3. Mongoid numeric field coercion

Mongoid ≥ 7.5 (required for Rails 7 compat) tightened type coercion: a field
declared as `field :amount, type: BigDecimal` will now raise on values that
arrive as `Float` from a JSON-decoded hash, rather than silently casting.

### 4. `Money` object serialization

`Workarea::Money` wraps `BigDecimal` internally. If a `Money` instance is
serialized to the Rails cache (e.g. a memoized discount lookup), and the cache
is shared across a Rails 6 → Rails 7 deployment window (rolling restart or
canary), the `Marshal` or `MessagePack` payload may be incompatible.

---

## Detection

### 1. Search for implicit `BigDecimal` / `Money` JSON serialization

```sh
# Find places where BigDecimal values are passed directly to as_json / to_json
grep -rn "BigDecimal\|Workarea::Money\|\.money" app/ plugins/ --include="*.rb" \
  | grep -v "_spec.rb" \
  | grep "as_json\|to_json\|JSON\.generate\|\.to_h"
```

### 2. Check Mongoid field declarations

```sh
grep -rn "type: BigDecimal\|type: :big_decimal" app/ plugins/ --include="*.rb"
```

### 3. Run the price/total round-trip test

Add a quick sanity test (or run existing order specs) and look for floating-point
equality failures:

```sh
bundle exec rspec spec/models/workarea/order_spec.rb \
  spec/models/workarea/pricing/ \
  --format progress 2>&1 | grep -E "Failure|FAILED|differ"
```

### 4. Check serialized cache payloads

If using Redis, inspect a cached value that should contain a `Money` or
`BigDecimal`:

```ruby
Rails.cache.fetch("workarea:pricing:some_key").class
# Expected: Workarea::Money or BigDecimal
# Symptom:  String or Float
```

---

## Fix

### A. Explicit `BigDecimal` coercion at JSON boundaries

Wherever a `BigDecimal` or `Money` value crosses a JSON boundary (API response,
cache write, serialized attribute), coerce explicitly on read:

```ruby
# Before (Rails 6, implicit)
amount = json_payload["amount"]   # => "9.99" (string) — silently used as BigDecimal

# After (Rails 7, explicit)
amount = BigDecimal(json_payload["amount"].to_s)
```

For `Money`:

```ruby
amount = Workarea::Money.from_amount(json_payload["amount"])
```

### B. Use `BigDecimal` custom serializer for `ActiveSupport::Cache`

In `config/initializers/big_decimal_cache.rb` (or in `workarea.rb`):

```ruby
# Ensure BigDecimal survives cache round-trips under Rails 7
module BigDecimalCachePatch
  def dump(entry)
    super
  end

  def load(payload)
    result = super
    # Deep-coerce if needed — implement per your cache structure
    result
  end
end
```

Alternatively, prefer `store_as: :string` in Mongoid field declarations and
always coerce on read:

```ruby
field :price, type: String   # store as string
def price
  BigDecimal(super.to_s) if super
end
```

### C. Clear shared cache during upgrade window

Before or during the Rails 7 deploy, flush all cache keys that may contain
serialized `Money` / `BigDecimal` objects:

```sh
rails runner "Rails.cache.delete_matched('workarea:pricing:*')"
# or full flush if safe:
rails runner "Rails.cache.clear"
```

### D. Pin `activerecord-typedstore` / `money-rails` to Rails-7-compatible versions

If the application uses `money-rails` or `active_attr`, ensure the pinned
versions declare Rails 7 compatibility and use `BigDecimal#to_s` for
serialization. Check their changelogs for "Rails 7" or "BigDecimal" entries.

---

## Workarea PR / Issue

- **This issue:** workarea-commerce/workarea#902 (WA-DOC-015 — documentation)
- Related verification issue: workarea-commerce/workarea#898 (WA-VERIFY-012 —
  regression suite for numeric type coercion across pricing and discounts)

> If you encounter a concrete Workarea code path that requires a fix (not just
> client application configuration), open a new issue referencing #902 with a
> failing spec and the affected file.

---

## Lint Rule (pseudocode)

The following pseudocode describes a custom RuboCop-style rule that could be
added to enforce explicit coercion at JSON/cache boundaries:

```
Rule: Workarea/BigDecimalJsonCoercion

Description:
  Flag any location where a Hash key access result is used directly in a
  monetary context (assigned to a Mongoid BigDecimal field, passed to Money.new,
  or used in arithmetic) without an explicit BigDecimal() or .to_d coercion.

Pattern (AST):
  (send
    (send _ :[] (str _))   # hash["key"]
    {arithmetic_op | :to_money | :to_d}
  )

OR

  (send
    (const _ :BigDecimal | :Money)
    :new
    (send _ :[] (str _))   # BigDecimal.new(hash["key"]) -- deprecated form
  )

Violation message:
  "Explicitly coerce JSON-sourced values to BigDecimal before monetary use.
   Use BigDecimal(value.to_s) or Workarea::Money.from_amount(value)."

Severity: warning

Autocorrect: suggest wrapping in BigDecimal((...).to_s)

Exclusions:
  - spec/**/*
  - db/seeds/**/*
```

---

## References

- [Rails 7.0 release notes — BigDecimal JSON](https://edgeguides.rubyonrails.org/7_0_release_notes.html)
- [Ruby 3.1 BigDecimal deprecations](https://www.ruby-lang.org/en/news/2021/12/25/ruby-3-1-0-released/)
- [Mongoid 7 type coercion changes](https://www.mongodb.com/docs/mongoid/current/tutorials/mongoid-documents/#fields)
- [`money-rails` Rails 7 compatibility notes](https://github.com/RubyMoney/money-rails/blob/main/CHANGELOG.md)
