---
title: Workarea 3.2.26
excerpt: Patch release notes for Workarea 3.2.26.
---

# Workarea 3.2.26

Patch release notes for Workarea 3.2.26.

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

