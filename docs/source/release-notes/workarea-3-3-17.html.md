---
title: Workarea 3.3.17
excerpt: Patch release notes for Workarea 3.3.17.
---

# Workarea 3.3.17

Patch release notes for Workarea 3.3.17.

## Cache Free Gift Product Details

The `OrderItemDetails` of the specified SKU in a "Free Gift" discount is
now being cached to optimize performance when reading data on the
discount. Its key is relative to the `Workarea::Discount::FreeGift` that
contains it, and differs by SKU.

### Issues

- [ECOMMERCE-6564](https://jira.tools.weblinc.com/browse/ECOMMERCE-6564)

### Pull Requests

- [3739](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3739/overview)

### Commits

- [1a681ebec969ab3536941cba8cdd587c29d349f7](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/1a681ebec969ab3536941cba8cdd587c29d349f7)

## Remove Favicon Generation From Rails App Template

The default app template generates a `public/favicon.ico` file in a newly
created Rails application, which causes a conflict since `/favicon.ico`
is a route defined by Workarea in order to serve the content asset
tagged as a "favicon". The `public/favicon.ico` file will now be removed
from all newly-generated Workarea v3.3+ applications.

### Issues

- [ECOMMERCE-6508](https://jira.tools.weblinc.com/browse/ECOMMERCE-6508)

### Pull Requests

- [3735](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3735/overview)

### Commits

- [391d08fea5f673465dc24cd822f928674364a0a0](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/391d08fea5f673465dc24cd822f928674364a0a0)

## Remove Redundant Port Binding in Generated Puma Configuration

Fix issues in hosting environments by removing a redundant port binding
to `:3000` in the auto-generated Puma configuration.

### Issues

- [ECOMMERCE-6558](https://jira.tools.weblinc.com/browse/ECOMMERCE-6558)

### Pull Requests

- [3732](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3732/overview)

### Commits

- [97b6b1b6c5f2cc5155d0874086a6ceaa55ec765a](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/97b6b1b6c5f2cc5155d0874086a6ceaa55ec765a)

## Fix Typo in Bulk Delete Success Message

Fix grammatical typo in the bulk delete flash message when the operation
is a success.

### Issues

- [ECOMMERCE-6553](https://jira.tools.weblinc.com/browse/ECOMMERCE-6553)

### Pull Requests

- [3740](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3740/overview)

### Commits

- [32022c72b7492e5fe12b0c1adf5605abd2245735](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/32022c72b7492e5fe12b0c1adf5605abd2245735)

