# Gemspec required_ruby_version Format Verification (WA-VERIFY-080)

**Date:** 2026-03-17  
**Issue:** #1062  
**Related:** WA-VERIFY-073 (PR #1050)

## Summary

Audited all Workarea gemspecs to confirm `required_ruby_version` format consistency.

## Findings

PR #1050 (WA-VERIFY-073) set the correct constraint value (`>= 2.7.0, < 3.5.0`) but
inadvertently wrote it in **array form** instead of **single-string form**.

| Gemspec | Before (array form) | After (single-string form) |
|---------|---------------------|---------------------------|
| `core/workarea-core.gemspec` | `['>= 2.7.0', '< 3.5.0']` | `'>= 2.7.0, < 3.5.0'` |
| `admin/workarea-admin.gemspec` | `['>= 2.7.0', '< 3.5.0']` | `'>= 2.7.0, < 3.5.0'` |
| `storefront/workarea-storefront.gemspec` | `['>= 2.7.0', '< 3.5.0']` | `'>= 2.7.0, < 3.5.0'` |
| `testing/workarea-testing.gemspec` | `['>= 2.7.0', '< 3.5.0']` | `'>= 2.7.0, < 3.5.0'` |
| `workarea.gemspec` | `['>= 2.7.0', '< 3.5.0']` | `'>= 2.7.0, < 3.5.0'` |

## Notes

Both forms are semantically equivalent in RubyGems. However, single-string form is the
canonical convention for gemspecs and is more readable. This change aligns all Workarea
gemspecs with that convention.
