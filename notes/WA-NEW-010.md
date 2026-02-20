# WA-NEW-010: Eliminate BSON Symbol deprecation warning

## Problem

Every test boot printed:

```
W, [...] WARN -- : The BSON symbol type is deprecated; use String instead
```

Stack trace pointed to:

```
mongoid-audit_log-0.6.1/lib/mongoid/audit_log/entry.rb:7
  field :action, :type => Symbol
```

`Mongoid::Fields::Validators::Macro#validate_options` (mongoid 7.4.x) fires a
one-time warning whenever a Mongoid field is declared with `type: Symbol`.
Since we can't patch the vendored gem directly, we need a two-part fix in our
own code.

## Root Cause

`mongoid-audit_log` defines its `Entry#action` field as `type: Symbol`. BSON
5.x deprecates the BSON Symbol wire type (0x0E) in favour of plain UTF-8
strings. Mongoid raises the warning when it registers any `Symbol`-typed field.

## Fix

### Part 1 — Silence the one-time warning flag (`freedom_patches/mongoid_audit_log.rb`)

`Mongoid::Fields::Validators::Macro` guards the warning with an instance
variable `@field_type_is_symbol_warned`. We pre-set it to `true` **before**
`require 'mongoid/audit_log'` so the gem's own field definition never emits the
warning. The inline comment explains why this suppression is safe (we
immediately override the field in our decorator).

### Part 2 — Re-declare the field as `String` (`ext/mongoid/audit_log_entry.rb`)

In our existing `decorate Entry` block we add:

```ruby
field :action, type: String, overwrite: true
```

This changes the stored BSON type from deprecated Symbol (0x0E) to String
(0x02) for all new audit-log entries.

We also add:

```ruby
def action
  super&.to_sym
end
```

This preserves the public contract: callers (including the gem's own
`create?`/`update?`/`destroy?` predicates) that compare `action == :create`
continue to work without changes.

## Compatibility Notes

- **Reads from existing data**: BSON Symbol values stored in MongoDB are
  decoded by the BSON driver as Ruby `Symbol`; Mongoid's String demongoizer
  calls `.to_s` on them, returning `"create"`. Our `#action` reader then calls
  `.to_sym`, yielding `:create`. Reads from old documents are unaffected.
- **Scopes** (`where(:action => :create)`): Mongoid casts the query value
  through the field's type (`String`), so `:create` becomes `"create"` in the
  query. New documents store `"create"`, so scopes match correctly.
- **Data migration**: Not required for application correctness (old BSON
  Symbol documents still read/display correctly). A background migration to
  convert stored symbols to strings can be done separately if desired.
- **Downstream client implementations**: No changes required. The `action`
  attribute still returns a `Symbol` value.

## Verification

```
bundle exec ruby -Icore/test core/test/lib/workarea/configuration/administrable/fieldset_test.rb
```

Before: warning emitted.  
After: warning gone, all 4 tests pass.

Also confirmed:
- `core/test/lib/workarea/ext/mongoid/audit_log_entry_test.rb` — 3 tests, 0 failures
- `core/test/middleware/workarea/audit_log_middleware_test.rb` — 1 test, 0 failures
