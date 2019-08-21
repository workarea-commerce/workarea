---
title: Workarea 3.3.20
excerpt: Patch release notes for Workarea 3.3.20.
---

# Workarea 3.3.20

Patch release notes for Workarea 3.3.20.

## Fix Scroll Position Bug for Pagination in Chrome for iOS

Replace the usage of `replaceState` with `pushState` so Chrome for iOS
will properly recall the scroll position of the previous page when
visiting a product from search results. This is caused by Chrome not
being capable of replacing state of a `History` object that doesn't yet
exist.

### Issues

- [ECOMMERCE-6652](https://jira.tools.weblinc.com/browse/ECOMMERCE-6652)

### Pull Requests

- [3835](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3835/overview)

### Commits

- [087aa93f4206cb6ed9f155ee1e924f973dcac35e](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/087aa93f4206cb6ed9f155ee1e924f973dcac35e)


## Return More Than 10 Results in Product Categories Admin

When finding categories for a product, provide a `:size` parameter equal
to the total count of all categories, so that any category on the system
that matches the product by rules can be viewed on the product's admin
page. Previously, since no `:size` param was applied, Elasticsearch
defaulted to returning 10 results.

Discovered (and solved) by Steph Staub. Thanks Steph!

### Issues

- [ECOMMERCE-5012](https://jira.tools.weblinc.com/browse/ECOMMERCE-5012)

### Pull Requests

- [3834](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3834/overview)

### Commits

- [f93b9ba8f9ebed2c1bb842ce4f8a53f431d5459b](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/f93b9ba8f9ebed2c1bb842ce4f8a53f431d5459b)

## Prevent Indexing of Unplaced Orders

The `IndexPaymentTransactions` worker did not previously check whether
the record should be indexed before trying to index it. This caused
unplaced orders to appear in the admin index. To remedy this, Workarea
now calls `#should_be_indexed?` on the search model prior to saving it
in Elasticsearch.

### Issues

- [ECOMMERCE-6649](https://jira.tools.weblinc.com/browse/ECOMMERCE-6649)

### Pull Requests

- [3813](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3813/overview)

### Commits

- [0658d82dddb72deff8f438685235f031fa7883f5](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/0658d82dddb72deff8f438685235f031fa7883f5)

## Fix Bulk Deletion From Query

An error would previously be thrown if one attempted to bulk-delete a
collection of a significant size, in which Workarea cannot use a list of
IDs but rather must use an Elasticsearch query to find the data to
remove. This query now functions properly and one can now bulk-delete a
collection of any size in Workarea.

### Issues

- [ECOMMERCE-6674](https://jira.tools.weblinc.com/browse/ECOMMERCE-6674)

### Pull Requests

- [3832](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3832/overview)

### Commits

- [e757de5e62c93a29ea53dc3d533696e6d31f61c2](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/e757de5e62c93a29ea53dc3d533696e6d31f61c2)

## Only Link Primary Navigation for Navigable Taxons

Taxons that are not navigable cannot be rendered with a `#link_to`,
because the href argument passed into the helper is `nil` and Rails is
converting that to the URL of the current page, making it appear as
though the link is pointing to the wrong place. Use `<span>` tags with
the same `.primary-nav__link` classes as the primary nav links in place
of `<a>` tags so these items are not clickable, but can be styled the
same as regular links.

Discovered by Mark Platt.

### Issues

- [ECOMMERCE-6556](https://jira.tools.weblinc.com/browse/ECOMMERCE-6556)

### Pull Requests

- [3798](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3798/overview)

### Commits

- [bd2b999a2cd377a913388ce58538e324616e6b07](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/bd2b999a2cd377a913388ce58538e324616e6b07)

