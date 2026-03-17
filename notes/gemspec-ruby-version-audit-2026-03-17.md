# WA-VERIFY-073 — Gemspec required_ruby_version audit

Date: 2026-03-17
Branch: `next`
Ruby in .ruby-version: `3.2.7`

## Findings

| Gemspec | required_ruby_version | Status |
|---------|----------------------|--------|
| `core/workarea-core.gemspec` | `>= 2.7.0, < 3.5.0` | ✅ Reasonable — allows 2.7–3.4 |
| `testing/workarea-testing.gemspec` | `>= 2.3.0` | ⚠️ Overly permissive — Ruby 2.3 is EOL, minimum should be 2.7 |
| `admin/workarea-admin.gemspec` | *(not set)* | ❌ Missing `required_ruby_version` |
| `storefront/workarea-storefront.gemspec` | *(not set)* | ❌ Missing `required_ruby_version` |
| `workarea.gemspec` (meta) | *(not set)* | ❌ Missing `required_ruby_version` |

## Recommended constraints

For consistency with `core` and the current CI matrix (Ruby 2.7–3.4):

```ruby
s.required_ruby_version = ['>= 2.7.0', '< 3.5.0']
```

This constraint:
- Excludes EOL Ruby < 2.7
- Allows all tested Ruby versions (2.7, 3.1, 3.2, 3.3)
- Gives headroom for 3.4 (tested in CI)
- Blocks 3.5+ until explicitly tested

## Recommended changes

1. **`testing/workarea-testing.gemspec`** — tighten to `>= 2.7.0, < 3.5.0`
2. **`admin/workarea-admin.gemspec`** — add `>= 2.7.0, < 3.5.0`
3. **`storefront/workarea-storefront.gemspec`** — add `>= 2.7.0, < 3.5.0`
4. **`workarea.gemspec`** (meta gem) — add `>= 2.7.0, < 3.5.0`

## Client Impact

Adding or tightening `required_ruby_version`:
- **Does not break existing installations** — Bundler uses this only at install time
- **Prevents installation on unsupported Rubies** (helps downstream clients avoid misconfigured setups)
- Requires a gem version bump only if tightening breaks someone on EOL Ruby (unlikely; Ruby 2.3–2.6 is EOL)

## Follow-up issues recommended

- Issue to update the 4 gemspecs with the recommended constraint
- Consider widening core upper bound to `< 4.0` once Ruby 3.5 is tested in CI
