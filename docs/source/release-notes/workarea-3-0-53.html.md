---
title: Workarea 3.0.53
excerpt: Patch release notes for Workarea 3.0.53.
---

# Workarea 3.0.53

Patch release notes for Workarea 3.0.53.

## Prevent Editing when Sorting Content Blocks

Allow blocks to be sorted without needing to open the Content Editing UI
at the end of the process.

### Issues

- [ECOMMERCE-6691](https://jira.tools.weblinc.com/browse/ECOMMERCE-6691)

### Pull Requests

- [3860](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3860/overview)

### Commits

- [b335fbc22707f460dfdbdce2847ec65dcc17a940](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b335fbc22707f460dfdbdce2847ec65dcc17a940)

## Mark Store Credit "Authorize" Transactions as "Purchase" Actions

When managing orders, particularly refunds and cancellations, store
credit would not be processed correctly since there is no capturing
of store credit funds. Setting the authorization transaction as a
purchase transaction allows orders with store credit to be canceled
and refunded as expected.

### Issues

- [ECOMMERCE-6689](https://jira.tools.weblinc.com/browse/ECOMMERCE-6689)

### Pull Requests

- [3858](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3858/overview)

### Commits

- [a71bc449e68a6a36e1b485c51f13f50cd6da0f8e](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/a71bc449e68a6a36e1b485c51f13f50cd6da0f8e)

## Expire Extra Admin Cookies

The `:analytics` and `:cache` cookies were not being expired at the
same time as `:user_id`, resulting in those cookies lingering around
after an admin's session has expired. This causes errors when developers
are testing things related to cache and analytics, because those cookies
prevent the aforementioned functionality from succeeding. Workarea now
expires these cookies at the same time as the user ID, rather than just
when the session no longer exists.

### Issues

- [ECOMMERCE-6369](https://jira.tools.weblinc.com/browse/ECOMMERCE-6369)

### Pull Requests

- [3851](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3851/overview)

### Commits

- [583f6a21c0891065c4b6a0331b12c375f2cb7a35](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/583f6a21c0891065c4b6a0331b12c375f2cb7a35)

## Fix Floating Select2 "Clear" Action in Admin

Workarea now prevents the "Clear" action from appearing within a single (that
is, not multi-select) Select2 UI.

### Issues

- [ECOMMERCE-6704](https://jira.tools.weblinc.com/browse/ECOMMERCE-6704)

### Pull Requests

- [3868](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3868/overview)

### Commits

- [f7d0b50ba4f345df43c6d602192c4fd7bb22cb6b](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/f7d0b50ba4f345df43c6d602192c4fd7bb22cb6b)

## Fix Inability to Remove Navigable Association from Taxon Through the Admin

When associating part of the taxonomy with a "navigable" page, category,
or product, admins were not able to remove the association later on if
they so chose. The `Navigation::Taxon#navigable` property would only be
set if a navigable object was sent over in params, and this contrasts
with how Select2 is implemented to send over a blank value when no
selection is made. Workarea will now always set the navigable to the
contents of the params.

### Issues

- [ECOMMERCE-6682](https://jira.tools.weblinc.com/browse/ECOMMERCE-6682)

### Pull Requests

- [3853](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3853/overview)

### Commits

- [8d56a297898d19dc852e1062c8f7a1d6ead3cfc7](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/8d56a297898d19dc852e1062c8f7a1d6ead3cfc7)

## Prevent Current Release from Being Set When Managing Comments

Commenting on a `Releasable` model while editing a `Release` can cause
the loss of release changes when a `Comment` updates the subscribers of the
`Commentable`. Workarea now prevents this by not setting the current release
when adding comments.

### Issues

- [ECOMMERCE-6701](https://jira.tools.weblinc.com/browse/ECOMMERCE-6701)

### Pull Requests

- [3857](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3857/overview)

### Commits

- [9551eab14e484cfd1625ced22eb4f2b3324ce16b](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/9551eab14e484cfd1625ced22eb4f2b3324ce16b)

