---
title: Workarea 3.1.42
excerpt: Patch release notes for Workarea 3.1.42.
---

# Workarea 3.1.42

Patch release notes for Workarea 3.1.42.

## Fix Copy on "New Primary Navigation" Admin Page

Remove an extra `'` in the description for the "New Primary Navigation".

Discovered by **Kristin Everham**. Thanks Kristin!

### Issues

- [ECOMMERCE-6702](https://jira.tools.weblinc.com/browse/ECOMMERCE-6702)

### Pull Requests

- [3928](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3928/overview)

## Fix Semi-Random, Frequent Logouts in Production

Fixes a bug in deployed environments where the stored client IP
(`REMOTE_ADDR`) was persisting between requests, resulting in incorrect
IPs being reported to the application and therefore confusing the
client-side session data. This caused semi-random, frequent logouts for
admins. It was fixed upstream in the Puma project, so the change in
Workarea is just to upgrade Puma

**More Information:** https://github.com/puma/puma/pull/1737

### Issues

- [ECOMMERCE-6810](https://jira.tools.weblinc.com/browse/ECOMMERCE-6810)

### Pull Requests

- [3937](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3937/overview)

## Reset Current Release After an Error Occurs

Similar to a recently discovered bug in Sidekiq callbacks, the current
release was not being reset to its previous value. If an error is raised
in the block passed to `Release.with_current`, the current release will
never get set back, and this can cause some strange errors in the UI.
Set the current release back to its previous value in the `ensure`
clause of the `.with_current` method.

### Issues

- [ECOMMERCE-6759](https://jira.tools.weblinc.com/browse/ECOMMERCE-6759)

### Pull Requests

- [3922](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3922/overview)

## Update Label Attributes in Cloned Row

In `WORKAREA.cloneableRows`, the `id` of any `<input>` element that is
cloned will be updated to have the suffix of `_cloned`, in order to
differentiate it from the original element. This logic has been carried
over to `<label>` elements so the `for` and `id` values match for each
cloned row.

### Issues

- [ECOMMERCE-5931](https://jira.tools.weblinc.com/browse/ECOMMERCE-5931)

### Pull Requests

- [3913](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3913/overview)

## Upgrade i18n.js and Fix Exclusions for Faker Translations

Changes in the `i18n-js` gem caused the patched exclusions to stop
working. To take advantage of the new exclusions API in the gem, the
version has been upgraded and the patch replaced with a configuration
setting.

### Issues

- [ECOMMERCE-6808](https://jira.tools.weblinc.com/browse/ECOMMERCE-6808)

### Pull Requests

- [3934](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3934/overview)

## Use Strings for IDs in IndexCategoryChangesTest

The test data in `Workarea::IndexCategoryChangesTest` used actual
Integers instead of IDs for the test data, which is different from a
real-world scenario in which Strings would be used. Replace all numbers
with Strings in `#test_require_index_ids` to resolve this issue.

### Issues

- [ECOMMERCE-6803](https://jira.tools.weblinc.com/browse/ECOMMERCE-6803)

### Pull Requests

- [3930](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3930/overview)

