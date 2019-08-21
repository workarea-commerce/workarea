---
title: Workarea 3.3.24
excerpt: Patch release notes for Workarea 3.3.24.
---

# Workarea 3.3.24

Patch release notes for Workarea 3.3.24.

## Fix Occasionally Failing Test Around Marking Discounts Redeemed

Specify a sort so that MongoDB doesn't use its own default sort, causing
entries in the collection to appear out-of-order and the test to fail
inconsistently.

### Issues

- [ECOMMERCE-6818](https://jira.tools.weblinc.com/browse/ECOMMERCE-6818)

### Pull Requests

- [3953](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3953/overview)

## Fix Slow Export Samples for Large Collections

The `skip` that is done to get random samples can be quite slow if
MongoDB needs to page. Instead, Workarea now grabs the first N entries
in the collection, since they don't really need to be random.

### Issues

- [ECOMMERCE-6813](https://jira.tools.weblinc.com/browse/ECOMMERCE-6813)

### Pull Requests

- [3943](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3943/overview)

## Inherit from ApplicationController Consistently

All admin controllers now inherit from `Admin::ApplicationController`.
Some autoloading edge cases caused this indented module reference to not
get picked up properly.

### Issues

- [ECOMMERCE-6816](https://jira.tools.weblinc.com/browse/ECOMMERCE-6816)

### Pull Requests

- [3947](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3947/overview)

## Fix Bulk Edit/Delete Entries Not Appearing in Trash

A carry-over from the v2.x days, `Mongoid::AuditLog` entries were not
recorded when performing within background jobs. Since bulk actions
occur in the background, entries for documents edited/deleted in this
manner were not appearing in the trash, and therefore not possible to
restore without developer intervention. This constraint is now removed,
and items deleted/edited within a bulk action will now appear as
individual items in the trash, and attributed to the user who performed
the bulk action.

### Issues

- [ECOMMERCE-6812](https://jira.tools.weblinc.com/browse/ECOMMERCE-6812)

### Pull Requests

- [3939](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3939/overview)

