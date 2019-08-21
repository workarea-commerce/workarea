---
title: Workarea 3.3.31
excerpt: Patch release notes for Workarea 3.3.31.
---

# Workarea 3.3.31

Patch release notes for Workarea 3.3.31.

## Omit Missing Options From Product Cache Key

The `#details_in_options` method, meant for including any options passed
to the `CacheKey` so long as they appear in details, would error if the
name of an option was `nil`. Workarea now ensures that those options
will be omitted.

### Issues

- [ECOMMERCE-6986](https://jira.tools.weblinc.com/browse/ECOMMERCE-6986)

### Pull Requests

- [4117](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4117)

## Remove Support For Restoring Taxons Without Parents

`Navigation::Taxon` documents whose parents no longer exist cannot be
restored because they are too dependent on their external relations,
such as `:parent_ids`. This causes issues on restore when one attempts
to restore a child taxon without restoring its parent. To prevent this
potential issue, taxons are never allowed to be restored from the trash.
The recommended alternative is to just create another taxon.

### Issues

- [ECOMMERCE-6983](https://jira.tools.weblinc.com/browse/ECOMMERCE-6983)

### Pull Requests

- [4116](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4116/overview)

## Improve Data Cache Busting for Discounts, SKUs, and Navigation

Workarea now calls the `BustSkuCache`, `BustDiscountCache`, and
`BustNavigationCache` workers inline around every request in the admin,
since admins expect this to be occurring in real-time. This also busts the
shipping service cache when a `Shipping::Service` is removed.

### Issues

- [ECOMMERCE-6981](https://jira.tools.weblinc.com/browse/ECOMMERCE-6981)

### Pull Requests

- [4110](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4110/overview)


