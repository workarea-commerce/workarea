---
title: Workarea 3.4.43
excerpt: Patch release notes for Workarea 3.4.43.
---

# Workarea 3.4.43

Patch release notes for Workarea 3.4.43

## Merge metrics when a user's email is updated

This ensures the old metrics info stays around after the email change.

### Pull Requests

- [542](https://github.com/workarea-commerce/workarea/pull/542)

## Include referrer in ending impersonation redirect fallbacks

When ending an impersonation, this changes to allow redirecting to the referrer
if the return_to parameter isn't present. Better UX for ending
impersonations while working in the admin.

### Pull Requests

- [543](https://github.com/workarea-commerce/workarea/pull/543)

## Add note to category default sort edit

The selected `default_sort` of a category will be always used in the
storefront. If the category contains featured products, this sort will
be labeled "Featured", and this might prove confusing to some admins.
To resolve this, add a note just below the dropdown indicating what will
occur when products are featured in the category.

### Pull Requests

- [544](https://github.com/workarea-commerce/workarea/pull/544)

## Add metrics explanation for users

This additional explanation is meant to communicate why customer
insights may occasionally mismatch with the orders card.

### Pull Requests

- [548](https://github.com/workarea-commerce/workarea/pull/548)

## Be more specific when matching reverts in changelogs

This change will allow starting commit messages with the word Revert
without the changelog task ignoring the commit.

### Pull Requests

- [549](https://github.com/workarea-commerce/workarea/pull/549)
