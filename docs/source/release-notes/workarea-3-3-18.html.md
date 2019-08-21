---
title: Workarea 3.3.18
excerpt: Patch release notes for Workarea 3.3.18.
---

# Workarea 3.3.18

Patch release notes for Workarea 3.3.18.

## Optionally Find Order Item Details by Product ID

When merchants market the same SKU across multiple products,
`OrderItemDetails` needs to know the `product_id` in order to find the
correct details hash for the variant. Update `OrderItemDetails.find` to
accept an optional `:product_id` keyword argument, which will be used
in the query to find a product variant if provided.

### Issues

- [ECOMMERCE-6554](https://jira.tools.weblinc.com/browse/ECOMMERCE-6554)

### Pull Requests

- [3742](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3742/overview)

### Commits

- [d5b700f2e570f8cd45cb4493bf8684cf7ceb3c18](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/d5b700f2e570f8cd45cb4493bf8684cf7ceb3c18)

## Fix ESLint Path Syntax in CI Scripts

In **workarea-ci**, the `eslint` task was not running against all JS files
in the project, instead only picking the first match off the top of the
wildcard list. This seems to be due to `yarn run`'s way of interpreting
the wildcard argument given to it. Use a different syntax, `.`, to have
ESLint go through all files recursively in the current directory, and
ignore the `node_modules/` folder with the `--ignore-paths` flag to
ESLint.

### Issues

- [ECOMMERCE-6544](https://jira.tools.weblinc.com/browse/ECOMMERCE-6544)

### Pull Requests

- [3757](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3757/overview)
- [3781](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3781/overview)

### Commits

- [a5f4aa3b664d99429adfd0e4072ded65c67220f4](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3781/commits/a5f4aa3b664d99429adfd0e4072ded65c67220f4)
- [482af0fdf33de02128425458d5c0874c0c462d30](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/482af0fdf33de02128425458d5c0874c0c462d30)

## Stop Admin Toolbar Session Refresh loop

When an admin's session expires, the toolbar can go into an infinite
loop of refreshing the login page now that the client can no longer be
authenticated. Prevent the admin toolbar from attempting to display when
a user is not authenticated.

### Issues

- [ECOMMERCE-6023](https://jira.tools.weblinc.com/browse/ECOMMERCE-6023)

### Pull Requests

- [3770](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3770/overview)

### Commits

- [7cb86763fc8df944e0ee9171de55e9f8e05944fe](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/7cb86763fc8df944e0ee9171de55e9f8e05944fe)

- [3ac62f7ea211ea96f00d5a34b734048df5b95d1e](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/3ac62f7ea211ea96f00d5a34b734048df5b95d1e)

## Fix Time Zone Specification on Cron Jobs

**config/initializers/05_scheduled_jobs.rb** had duplicate jobs
specified without timezone, and additional jobs that never had the
timezone specified. This was caused by an upstream merge that Git applied
incorrecctly. All cron jobs are now unique and specify the time
zone.

### Issues

- [ECOMMERCE-6578](https://jira.tools.weblinc.com/browse/ECOMMERCE-6578)

### Pull Requests

- [3744](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3744/overview)

### Commits

- [0022513c9abd0f3ae8498328e6074346f4fb06d2](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/0022513c9abd0f3ae8498328e6074346f4fb06d2)

## Support Callable URL Host In Dragonfly

Workarea automatically sets the `Rails.configuration.asset_host` to
Dragonfly's `url_host`, which is useful in production to ensure all
uploaded assets are going through the CDN, but caused problems for
multi-site applications because their `asset_host` out-of-box is set
to a `lambda` instead of a regular String. The maintainer of Dragonfly
has been notified about this issue, but in the meantime, Dragonfly has
been patched to allow this functionality and subsequently fix out-of-box
multi-site installations.

This functionality has also been provided [as an upstream patch to
Dragonfly](https://github.com/markevans/dragonfly/pull/502), but has not
yet been merged.


### Issues

- [ECOMMERCE-6580](https://jira.tools.weblinc.com/browse/ECOMMERCE-6580)

### Pull Requests

- [3765](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3765/overview)

### Commits

- [a0569e032b3a9159fbef7350ff237f5474fad7bb](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/a0569e032b3a9159fbef7350ff237f5474fad7bb)

## Truncate Taxon Names In Menu Builder

In the Taxonomy menu builder, long taxon names have the potential to
overlap the "Primary Navigation" edit link text, available when the
taxon is a primary menu. The taxon's name is now truncated if the
"Primary Navigation" link is going to appear next to it, allowing for
longer names to span the full width of the menu if the link isn't going
to be rendered.

### Issues

- [ECOMMERCE-5333](https://jira.tools.weblinc.com/browse/ECOMMERCE-5333)

### Pull Requests

- [3755](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3755/overview)

### Commits

- [c7e76e5e0428136d034dec7612c16e40a2d1903e](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c7e76e5e0428136d034dec7612c16e40a2d1903e)

## Use Elasticsearch Scroll API for Exports

Exporting more than 10,000 records from any given Workarea collection
previously threw an Elasticsearch error when the export began
processing, with a note in the error to use the [Scroll API](https://www.elastic.co/guide/en/elasticsearch/reference/5.6/search-request-scroll.html)
to more efficiently find the necessary results. As a result, Workarea
now has scroll API support in the Elasticsearch adapter libraries,
accessible using `Search::Query#scroll` and
`AdminSearchQueryWrapper#scroll`.

### Issues

- [ECOMMERCE-6591](https://jira.tools.weblinc.com/browse/ECOMMERCE-6591)

### Pull Requests

- [3780](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3780/overview)

### Commits

- [b20067b720956ba1f5b67bc9292e66eaa5c84c1b](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b20067b720956ba1f5b67bc9292e66eaa5c84c1b)

