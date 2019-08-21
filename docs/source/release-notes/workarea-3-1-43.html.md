---
title: Workarea 3.1.43
excerpt: Patch release notes for Workarea 3.1.43.
---

# Workarea 3.1.43

Patch release notes for Workarea 3.1.43.

## Fix Occasionally Failing Test Around Marking Discounts Redeemed

Specify a sort so that MongoDB doesn't use its own default sort, causing
entries in the collection to appear out-of-order and the test to fail
inconsistently.

### Issues

- [ECOMMERCE-6818](https://jira.tools.weblinc.com/browse/ECOMMERCE-6818)

### Pull Requests

- [3953](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3953/overview)

## Inherit from ApplicationController Consistently

All admin controllers now inherit from `Admin::ApplicationController`.
Some autoloading edge cases caused this indented module reference to not
get picked up properly.

### Issues

- [ECOMMERCE-6816](https://jira.tools.weblinc.com/browse/ECOMMERCE-6816)

### Pull Requests

- [3947](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3947/overview)

