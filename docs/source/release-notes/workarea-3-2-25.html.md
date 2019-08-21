---
title: Workarea 3.2.25
excerpt: Patch release notes for Workarea 3.2.25.
---

# Workarea 3.2.25

Patch release notes for Workarea 3.2.25.

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

