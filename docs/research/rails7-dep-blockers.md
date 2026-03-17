# Rails 7 Dependency Blockers

**Date:** 2026-03-01  
**Issue:** [#687](https://github.com/workarea-commerce/workarea/issues/687) — WA-RAILS7-001: Widen Rails dependency

## Summary

After widening `workarea-core.gemspec` to `>= 6.1, < 7.2`:

| Rails version | Resolution |
|---|---|
| 6.1.x (current) | ✅ Resolves and installs successfully |
| 7.0.x | ✅ Resolves and installs successfully |
| 7.1.x | ❌ Blocked (see below) |

## Rails 7.1 Blockers

### 1. `loofah` version pin (primary blocker)

**gemspec pin:** `loofah ~> 2.9.0` (i.e., `>= 2.9.0, < 2.10`)  
**Rails 7.1 requires:** `rails-html-sanitizer ~> 1.6` → requires `loofah >= 2.21`

These are incompatible. Widening the `loofah` pin in the gemspec is required before Rails 7.1 can resolve.

**File:** `core/workarea-core.gemspec`  
**Current:** `s.add_dependency 'loofah', '~> 2.9.0'`  
**Needed for 7.1:** `s.add_dependency 'loofah', '>= 2.9', '< 3'` (or similar)

**Risk:** loofah is a security-sensitive HTML sanitizer library. Upgrading from 2.9 to 2.21+ spans many releases; API compatibility and behavioral changes should be tested carefully, especially for any XSS-sensitive sanitization paths in Workarea's admin/storefront.

## Rails 7.0 Status

Rails 7.0 resolves cleanly against the gemspec with only the `rails` version constraint widened. No additional gemspec changes are required for 7.0 dependency resolution.

## Next Steps

1. **Rails 7.0 path:** Ready for runtime/test validation — dependency resolution confirmed clean.
2. **Rails 7.1 path:** Open a follow-up issue to widen the `loofah` pin and validate HTML sanitization behavior.

## Test Environment

- Ruby: 3.2.7
- Bundler: system bundler via rbenv

Note: Ruby 2.7.x is still the Rails 7 minimum, but Ruby 2.7 is end-of-life. Use Ruby 2.7.8 only for legacy branches/apps pinned to Ruby 2.7.
- Test method: isolated `Gemfile` with `gemspec path:` pointing to `core/` and an explicit Rails version pin
