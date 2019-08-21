---
title: Workarea 3.2.8
excerpt:  There was some configuration preventing SVGs from being displayed in the WYSIWYG editor. Although we fixed this issue a few patch versions back, it reared its ugly head recently due to a change in how InlineSvg set its initial asset finder. In an att
---

# Workarea 3.2.8

## Missing SVGs in WYSIWYG Editor

There was some configuration preventing SVGs from being displayed in the WYSIWYG editor. Although we fixed this issue a few patch versions back, it reared its ugly head recently due to a change in how `InlineSvg` set its initial asset finder. In an attempt to preserve existing functionality and prevent problems, we conditionally add our own asset finder if the finder in `InlineSvg` wasn't going to work for us. However, the gem now configures this asset finder after we are configuring our own, making that conditional configuration no longer possible. We're now only setting `InlineSvg.config.asset_finder` if the asset finder hasn't already been set.

### Issues

- 

### Pull Requests

- [3318](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3318)

### Commits

- [17320cddfcd92081ee96425b163a02fb69b42c98](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/17320cddfcd92081ee96425b163a02fb69b42c98)

## Fix Gemspec Changes when Generating Plugins

The `.gemspec` file for new plugins was not being generated properly. Fix what we were searching for to find and replace in order to add the `s.add_dependency 'workarea'` line properly.

### Issues

- [ECOMMERCE-6002](https://jira.tools.weblinc.com/browse/ECOMMERCE-6002)

### Pull Requests

- [3330](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3330)

### Commits

- [333c42dd5d307594ed257d0526e7005af8d7d476](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/333c42dd5d307594ed257d0526e7005af8d7d476)

## Make All Base Tests Work when Changing Time Zone

When setting `Rails.application.config.time_zone` to eastern time, some tests surrounding deprecated order queries were failing because they're not converting to the Rails timezone. Adding `#in_timezone` to each of the dates put them in the correct timezone, causing the query to find the correct data and tests to pass once again.

### Issues

- [ECOMMERCE-5823](https://jira.tools.weblinc.com/browse/ECOMMERCE-5823)

### Pull Requests

- [3337](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3337)

### Commits

- [7ddb82f97224784c4dae75a1d3007292df15faa1](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/7ddb82f97224784c4dae75a1d3007292df15faa1)

## Fix Ordering for Embedded Documents

When a model is embedded within another model, the object given back is not always a `Mongoid::Criteria`, causing some strange issues when using (or decorating) one of these models. Update the `Workarea::Ordering` mixin to explicitly return the parent's criteria when finding siblings of a given document.

### Issues

- [ECOMMERCE-5983](https://jira.tools.weblinc.com/browse/ECOMMERCE-5983)

### Pull Requests

- [3317](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3317)

### Commits

- [f4f88ce95f73e8a24dd7245d9dd864e7477610e6](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/f4f88ce95f73e8a24dd7245d9dd864e7477610e6)

## Disallow Search Customizations for "\*" Queries

The Elasticsearch `*` query has special meaning, always returning all documents in the index in whatever faceting/ordering you specify. They won't be deleteable as of v3.2, so it's best to just not allow admins to create search customizations for the "\*" query at all.

### Issues

- [ECOMMERCE-5335](https://jira.tools.weblinc.com/browse/ECOMMERCE-5335)

### Pull Requests

- [3303](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3303)

### Commits

- [0625ea31e983178997ed6f3d10d3cc4cdff0873a](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/0625ea31e983178997ed6f3d10d3cc4cdff0873a)

## Fix Discrepancy in "Missing Variants" Alert

The alert for missing variants renders a different number than what is actually on the page. The link to the results of this query tacks on an additional `?status=active` flag to filter out products that are inactive. This is inconsistent with the number displayed on the alert, which has no condition. Since products missing variants are by default inactive, we are removing this additional param as it serves no purpose anymore. The amount of products with missing variants in the alert and the amount of products on the results page are now equal.

### Issues

- [ECOMMERCE-5833](https://jira.tools.weblinc.com/browse/ECOMMERCE-5833)

### Pull Requests

- [3322](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3322)

### Commits

- [6bc7754294761aa3d14c394b6252d6bdc5442364](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/6bc7754294761aa3d14c394b6252d6bdc5442364)

## Define Reverse Association from Fulfillment::Item to Fulfillment

The lack of this reverse association caused some cognitive overhead, but was also the root cause of a bug involving Mongoid's atomic updates system, which produced an error in the admin when attempting to update fulfillment items.

### Issues

- [ECOMMERCE-5723](https://jira.tools.weblinc.com/browse/ECOMMERCE-5723)

### Pull Requests

- [3321](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3321)

### Commits

- [17e50a0503ca5a5d3a07dded31a538453eccb742](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/17e50a0503ca5a5d3a07dded31a538453eccb742)

## Show Category Name in the Timeline when Updating Category Product Rules

When updating a product rule based on a given category, we're now showing the category's full name in the timeline rather than its BSON ID. This helps identify the categories added/removed to another category's rules.

RIP Dave Barnow.

### Issues

- [ECOMMERCE-5960](https://jira.tools.weblinc.com/browse/ECOMMERCE-5960)

### Pull Requests

- [3293](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3293)

### Commits

- [8c625f94490c940e674cadeb9bfcbbdd4ba91405](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/8c625f94490c940e674cadeb9bfcbbdd4ba91405)

