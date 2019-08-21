---
title: Workarea 3.1.35
excerpt: Patch release notes for Workarea 3.1.35.
---

# Workarea 3.1.35

Patch release notes for Workarea 3.1.35.

## Remove Unused Class from Inline Form Style Guide

Omit the `.value__error` CSS class from the `inline-form` component in
the storefront style guide, as this class is not applied to the `text-box`
element depicted in the style guide in the real world.

### Issues

- [ECOMMERCE-6504](https://jira.tools.weblinc.com/browse/ECOMMERCE-6504)

### Pull Requests

- [3721](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3721/overview)

### Commits

- [6e39aa7e5e3053b5ce055dfd262eaffd78d894b9](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/6e39aa7e5e3053b5ce055dfd262eaffd78d894b9)

## Force Dragonfly Attachments to Be Private In S3

When uploading Dragonfly attachments to Amazon S3, ensure the raw file
blobs are not accessible in the public domain by setting the HTTP header
`X-Amz-Acl: private` when making storage requests to the S3 API. This
header ensures that any files, from this point forward, will not be
accessible by any entity. Workarea now ensures that only the
application, with the proper access keys, can read the raw attachments
uploaded by Dragonfly, providing proper application-level access control
as needed.

### Issues

- [ECOMMERCE-6520](https://jira.tools.weblinc.com/browse/ECOMMERCE-6520)

### Pull Requests

- [3714](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3714/overview)

### Commits

- [6cf916aaa986fb08eb7b1715726671079f5f060a](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/6cf916aaa986fb08eb7b1715726671079f5f060a)
- [22aa0c9a63dcea4d9692210781cae2606d306abc](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/22aa0c9a63dcea4d9692210781cae2606d306abc)
- [701afe81da8b55df7e5c9594c54cbe89e91163fa](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/701afe81da8b55df7e5c9594c54cbe89e91163fa)
- [26c2e283815829b3fab9b7c02e4e889738bd3896](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/26c2e283815829b3fab9b7c02e4e889738bd3896)
- [cf6ee03666794221ae64bba8cc6b5d0f6ff87349](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/cf6ee03666794221ae64bba8cc6b5d0f6ff87349)
- [2bf89f06cefd47e15ba9f07a63c42fc591f444f6](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/2bf89f06cefd47e15ba9f07a63c42fc591f444f6)

## Remove Axis Configuration on Sortable Nav Menus in Admin

Sortable navigation menus in the admin had problems on smaller screen
devices (or with large amounts of menus) when the pills take up more
than one line. Removing the `axis: 'x'` configuration resolves the
issue, and isn't truly necessary in order to get a working sort.

### Issues

- [ECOMMERCE-6545](https://jira.tools.weblinc.com/browse/ECOMMERCE-6545)

### Pull Requests

- [3724](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3724/overview)

### Commits

- [f3b0f4015072d21aff4d75f3e917e376231d47c7](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/f3b0f4015072d21aff4d75f3e917e376231d47c7)

## Remove `Admin::TaxonomySystemTest#test_content_blocks`

This test causes intermittent issues on CI builds and thus blocks
deployment for implementation teams. Remove the test, since it doesn't
help anyone to have something that is almost never customized fail for
indeterminate reasons.

### Issues

- [ECOMMERCE-6482](https://jira.tools.weblinc.com/browse/ECOMMERCE-6482)

### Pull Requests

- [3710](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3710/overview)

### Commits

- [ae87b864109b1cd240a0c9671ee83de725ac0223](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ae87b864109b1cd240a0c9671ee83de725ac0223)

## Order Regions By Name In Addresses Form

In the `<select>` tag defining all possible region options for the
currently selected country, Workarea previously ordered the `<option>`
tags by their value. They are now being sorted by the display name of
the region to prevent issues where they appear out-of-order to the end
user.


### Issues

- [ECOMMERCE-6311](https://jira.tools.weblinc.com/browse/ECOMMERCE-6311)

### Pull Requests

- [3707](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3707/overview)

### Commits

- [fd3445972fd41dc56f66967a8af207dd2dc1aed6](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/fd3445972fd41dc56f66967a8af207dd2dc1aed6)

## Disable Change Admin Password Form in Ajax Requests

When a `GET` request is made via Ajax, Workarea previously rendered the
"Change Password" form for admins who have expired passwords. This
caused visual problems when requesting things like product details or
navigation menus until the password was changed. If requested via XHR,
Workarea now returns a `401 Unauthorized` response (instead of displaying
the requested content) with no content if the current user's password needs
to be reset.

### Issues

- [ECOMMERCE-5690](https://jira.tools.weblinc.com/browse/ECOMMERCE-5690)

### Pull Requests

- [3700](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3700/overview)

### Commits

- [7555af15ce62c41ac9afb3d6aedf0ddb9444c503](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/7555af15ce62c41ac9afb3d6aedf0ddb9444c503)

## Search Products By Filter Values In Admin

In previous versions of Workarea, filter values (e.g., for the filter
"Color", values would be "Red" and "Blue") could be entered into the
admin search and the product(s) that match those hues would be
returned. This changed at some point when v3 was released and the search
system was refactored.

### Issues

- [ECOMMERCE-6050](https://jira.tools.weblinc.com/browse/ECOMMERCE-6050)

### Pull Requests

- [3702](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3702/overview)

### Commits

- [c4eeb88e825b881bff845f7d0d47644d0bbff63f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c4eeb88e825b881bff845f7d0d47644d0bbff63f)

## Optimize `BulkIndexProducts` for Large Amounts of Featured Products

By default, Workarea reindexes all products featured in a category in a
single request using the `BulkIndexProducts` worker. However, if this
set of featured products grows too large, this worker must store a large
amount of data in memory, thus causing issues in production where the
job is terminated for over-consumption of memory. To prevent this,
Workarea will now enqueue `BulkIndexProducts` in batches of (by default) 100 if the
amount of featured products in a category is over 100. This value is
configurable using `Workarea.config.category_inline_index_product_max_count`.

### Issues

- [ECOMMERCE-6480](https://jira.tools.weblinc.com/browse/ECOMMERCE-6480)

### Pull Requests

- [3704](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3704/overview)

### Commits

- [d2c7831f375bdb12265246120d7536ee6b57da1e](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/d2c7831f375bdb12265246120d7536ee6b57da1e)

