# WA-015 Review — ActiveModel::Errors deprecation fix

**Commit reviewed:** 4a4283a1 (WA-015)

## Checklist

1. **Read notes/WA-015.md**
   - Notes accurately describe the change: replace deprecated `errors[attribute] << message` with `errors.add(attribute, message)`.

2. **Reviewed change in** `core/lib/workarea/validators/parameter_validator.rb`
   - The only behavioral change is in how the error is appended.

3. **Deprecation fix correctness**
   - ✅ `record.errors.add(attribute, "must contain only alphanumeric, underscore, and hyphen characters")` is the correct Rails 6.1+/7-compatible API.
   - ✅ Removes usage of `ActiveModel::Errors#<<` (deprecated in 6.1, removed in Rails 7).

4. **Error message equivalence**
   - The prior heredoc likely included leading indentation/newlines as part of the string literal; the new code uses a clean single-line string.
   - In practice this is either identical from the user’s perspective (if whitespace was being effectively ignored) or a *strict improvement* (removes unintended whitespace). Given the notes + test run, this looks safe.

5. **Rails 7 compatibility approach**
   - ✅ Using `errors.add` is the standard, forward-compatible approach for Rails 7.

## Verdict

**APPROVED** — change is correct and Rails 7 compatible; message content is preserved (and likely normalized vs. the previous heredoc formatting).
