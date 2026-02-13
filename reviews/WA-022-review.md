# WA-022 Review

**Reviewer:** Kit (subagent)  
**Date:** 2026-02-12  
**Commit:** `8210fb16`  
**Verdict:** ✅ **APPROVED**

---

## Summary
This fix addresses `Errno::ENOENT` failures when `image_optim` attempts to shell out to `sysctl` in test environments with restricted PATH configurations (common in CI/sandboxed environments).

## Code Review

### Changes Made
**File:** `core/lib/workarea/core/engine.rb`

Added 10 lines within the existing `Rails.env.test?` block:
- Checks if `/usr/sbin/sysctl` exists
- Prepends `/usr/sbin` to `ENV['PATH']` if found
- Uses `.uniq` to avoid duplicate entries

### Assessment

✅ **Minimal & Surgical**  
- Only adds necessary logic to solve the specific problem
- No refactoring or scope creep
- Placed in the appropriate existing test-only block

✅ **Correct Implementation**  
- Defensive check for `/usr/sbin/sysctl` existence before PATH modification
- Proper PATH manipulation: split → prepend → deduplicate → rejoin
- Clear, detailed comment explaining the *why*

✅ **Properly Scoped**  
- Exclusively runs in `Rails.env.test?` block
- **Zero production impact** — no changes to development or production environments
- Targets the exact environment where the issue manifests

✅ **Well-Documented**  
- Inline comment explains the problem and solution
- `notes/WA-022.md` provides comprehensive context and verification steps

## Independent Verification

Ran the provided test with a restricted PATH (missing `/usr/sbin`):

```bash
cd storefront/test/dummy
RAILS_ENV=test PATH="$HOME/.rbenv/shims:$HOME/.rbenv/bin:/usr/bin:/bin" \
  bin/rails runner "require 'image_optim'; ImageOptim.new; puts 'ok'"
```

**Result:** ✅ **PASS**
- Printed `ok` successfully
- No `Errno::ENOENT: No such file or directory - sysctl` error
- Expected warnings about optional workers (`pngout`, `svgo`) appeared but are unrelated

## Recommendation

**APPROVED** for merge. This is a clean, minimal fix that:
- Solves the reported problem
- Has no side effects
- Is properly tested and documented
- Follows Rails conventions for environment-specific initialization

---

**No changes requested.**
