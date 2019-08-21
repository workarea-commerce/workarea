---
title: Workarea 3.4.3
excerpt: Patch release notes for Workarea 3.4.3.
---

# Workarea 3.4.3

Patch release notes for Workarea 3.4.3.

## Create Configuration for Insight Model Classes

Move `Admin::InsightViewModel::MODELS` to a configuration value called
`config.insights_model_classes` so it can be extended, and new insights
can be added for display on the dashboard.

### Issues

- [ECOMMERCE-6834](https://jira.tools.weblinc.com/browse/ECOMMERCE-6834)

### Pull Requests

- [3962](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3962/overview)

## Update App Template for Upgradability and Rails 5.2

Some errors were observed when using the `rails app:template` task with
the built-in app template for upgrade purposes, since there are a
significant amount of changes in the app template for v3.4 (like
auto-configuration). Workarea has replaced the usage of `@app_name` with
the `#app_name` method to ensure that it's set before attempting to
perform text processing operations, and the template will no longer
write to `Gemfile` if it doesn't have to. Additionally, the `Gemfile`
has been cleaned up by removing extra whitespace.

### Issues

- [ECOMMERCE-6821](https://jira.tools.weblinc.com/browse/ECOMMERCE-6821)
- [ECOMMERCE-6830](https://jira.tools.weblinc.com/browse/ECOMMERCE-6830)

### Pull Requests

- [3959](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3959/overview)
- [3961](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3961/overview)

## Prevent Logging Controller Parameters in Logstash

Logstasher was previously configured to send controller params in
Logstash logs, but this caused errors in Elasticsearch as each new param
became a new mapping as it was indexed. This very quickly exhausted the
amount of mappings allowed within the Elasticsearch index. Workarea no
longer enables this field out of the box, so that logstash will continue
to work as normal.


### Issues

- [ECOMMERCE-6829](https://jira.tools.weblinc.com/browse/ECOMMERCE-6829)

### Pull Requests

- [3960](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3960/overview)

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

## Remove "@" in Activity Time

Remove this character preceding the time of timeline activity so that it
reads better.

### Issues

- [ECOMMERCE-6817](https://jira.tools.weblinc.com/browse/ECOMMERCE-6817)

### Pull Requests

- [3952](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3952/overview)

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

