---
title: Fixing the Bundler Frozen-Mode Lockfile Mismatch in CI
created_at: 2026/03/16
excerpt: How to resolve the "gemspecs for path gems changed, but the lockfile can't be updated because frozen mode is set" CI failure.
---

# Fixing the Bundler Frozen-Mode Lockfile Mismatch in CI

## Symptom

CI fails with the following error:

```
The gemspecs for path gems changed, but the lockfile can't be updated because frozen mode is set.
```

This error means your `Gemfile.lock` is stale — the gemspec metadata for one or
more of Workarea's path gems (e.g. `workarea-core`, `workarea-admin`,
`workarea-storefront`) has changed since the lockfile was last generated, and
Bundler's `--frozen` flag (used in CI) prevents it from auto-updating.

This has blocked multiple PRs (e.g. #865, #866) and requires a **manual
lockfile regeneration** before CI can pass.

---

## Canonical Fix

Run these commands from the repo root in a **clean shell** (no local
`vendor/bundle` interference):

```bash
# 1. Ensure you are on the correct Ruby version for lockfile regeneration
rbenv local 3.2.7

# 2. Verify the active Ruby
ruby --version   # should print ruby 3.2.7

# 3. Regenerate the lockfile
bundle install

# 4. Commit the updated lockfile
git add Gemfile.lock
git commit -m "docs: regenerate Gemfile.lock for Ruby 3.2.7 gemspec changes"

# 5. Push to your branch
git push
```

CI should now pass.

---

## Common Gotchas

### Wrong Ruby version

Workarea uses **two distinct Ruby versions** in its development workflow:

| Purpose | Ruby version |
|---|---|
| Test suite (CI) | 2.7.8 |
| Lockfile regeneration / `bundle install` | 3.2.7 |

Running `bundle install` under Ruby 2.7.8 will produce a different `Gemfile.lock`
and may not resolve the frozen-mode error. Always use **3.2.7** for lockfile
regeneration.

To confirm your rbenv setup:

```bash
rbenv versions        # lists installed versions
rbenv install 3.2.7   # install if missing
rbenv local 3.2.7     # pin to 3.2.7 for this repo
ruby --version        # verify
```

### Local `vendor/bundle` surprises

If you have a local `vendor/bundle` directory (from a previous `bundle install
--path vendor/bundle`), Bundler may resolve against it instead of the system
gems and produce an unexpected lockfile. To rule this out:

```bash
# Temporarily move vendor/bundle out of the way, or use:
bundle config unset path
bundle install
```

You can also check your local Bundler config with `bundle config list`.

### Branch not based on `next`

Feature branches **must be based off `next`**, not `main` or a stable branch.
If you branched from the wrong base, the gemspecs on your branch may differ
from what `next` expects, triggering the frozen-mode error.

To rebase onto `next`:

```bash
git fetch origin
git rebase origin/next
# resolve any conflicts, then re-run bundle install
bundle install
git add Gemfile.lock
git commit --amend --no-edit
git push --force-with-lease
```

---

## Why frozen mode?

Workarea's CI pipeline runs Bundler with `BUNDLE_FROZEN=true` (equivalent to
`bundle install --frozen`). This ensures that CI always uses the exact gem
versions recorded in `Gemfile.lock`, preventing silent dependency drift between
local development and CI environments. The trade-off is that any gemspec change
requires an explicit lockfile update before CI can run.

---

## Related

- [Contribute Code](/articles/contribute-code.html)
- [Installing](/articles/installing.html)
- GitHub issues: #865, #866, #877
