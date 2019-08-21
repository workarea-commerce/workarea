---
title: Workarea 3.0.63
excerpt: Patch release notes for Workarea 3.0.63.
---

# Workarea 3.0.63

Patch release notes for Workarea 3.0.63.

## Improve Data Cache Busting for Discounts, SKUs, and Navigation

Workarea now calls the `BustSkuCache`, `BustDiscountCache`, and
`BustNavigationCache` workers inline around every request in the admin,
since admins expect this to be occurring in real-time. This also busts the
shipping service cache when a `Shipping::Service` is removed.

### Issues

- [ECOMMERCE-6981](https://jira.tools.weblinc.com/browse/ECOMMERCE-6981)

### Pull Requests

- [4110](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4110/overview)


