---
title: Workarea 3.1.5
excerpt: Uses a larger page size for bulk actions to reduce database queries and improve performance. Adds Workarea.config.bulk_action_per_page to configure the per-page value.
---

# Workarea 3.1.5

## Improves Bulk Action Performance

Uses a larger page size for bulk actions to reduce database queries and improve performance. Adds `Workarea.config.bulk_action_per_page` to configure the per-page value.

**If after this change you find your bulk action workers are using too much memory, reduce the value.**

### Issues

- [ECOMMERCE-5390](https://jira.tools.weblinc.com/browse/ECOMMERCE-5390)

### Pull Requests

- [2912](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2912/overview)

### Commits

- [1981a4df1682934edce0ecdff448a7b4c22b07fd](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/1981a4df1682934edce0ecdff448a7b4c22b07fd)
- [f55f0691a9881aa0f95ceeb8a078399ab286528a](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/f55f0691a9881aa0f95ceeb8a078399ab286528a)
- [32dd38e18c1615302986a742e708ba5830cfb8b0](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/32dd38e18c1615302986a742e708ba5830cfb8b0)

## Fixes Region Selection in Storefront Address Forms

Storefront address forms could select the wrong region on page load. This change updates `WORKAREA.addressRegionFields` to consider country when selecting the region, which fixes the issue.

### Issues

- [ECOMMERCE-5324](https://jira.tools.weblinc.com/browse/ECOMMERCE-5324)

### Pull Requests

- [2901](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2901/overview)

### Commits

- [6eb7dddbb794c1598c44547a905761178dd5809c](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/6eb7dddbb794c1598c44547a905761178dd5809c)
- [0106798d3a5086488fe6648289a13aa3a4f94121](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/0106798d3a5086488fe6648289a13aa3a4f94121)
- [196b8bb186b698c14ae474e8c725a3069f5f2be4](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/196b8bb186b698c14ae474e8c725a3069f5f2be4)
- [8b215de768a4a12bf4ade0715431c14243c28c31](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/8b215de768a4a12bf4ade0715431c14243c28c31)
- [32dd38e18c1615302986a742e708ba5830cfb8b0](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/32dd38e18c1615302986a742e708ba5830cfb8b0)

## Fixes Product Rule Preview When Updating a Rule

When editing an existing product rule (e.g. when editing a category), the preview could show incorrect matches. This change modifies the Admin product rules controller to fix the issue.

### Issues

- [ECOMMERCE-5420](https://jira.tools.weblinc.com/browse/ECOMMERCE-5420)

### Pull Requests

- [2915](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2915/overview)

### Commits

- [6161b40673b15b9b6161461ef36408d33a0dfd03](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/6161b40673b15b9b6161461ef36408d33a0dfd03)
- [ed89159ac365514d47f009057e27580c60e90085](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ed89159ac365514d47f009057e27580c60e90085)
- [32dd38e18c1615302986a742e708ba5830cfb8b0](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/32dd38e18c1615302986a742e708ba5830cfb8b0)

## Fixes Mapping Errors on Category Percolations

Category percolations could raise errors due to unmapped fields. To prevent this issue, this change modifies the `workarea:search_index:storefront` Rake task to index products representing all unique filters before indexing categories.

### Issues

- [ECOMMERCE-5435](https://jira.tools.weblinc.com/browse/ECOMMERCE-5435)

### Pull Requests

- [2924](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2924/overview)

### Commits

- [66bcc4f618a44915666d79b3cfd2f50457af6394](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/66bcc4f618a44915666d79b3cfd2f50457af6394)
- [4add203333996df30b3425e765cbfc0fb9bb2afb](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/4add203333996df30b3425e765cbfc0fb9bb2afb)
- [32dd38e18c1615302986a742e708ba5830cfb8b0](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/32dd38e18c1615302986a742e708ba5830cfb8b0)

## Fixes Saving Order Details to New User

Under certain circumstances, order details could incorrectly be saved to a new user account created by the customer while the completed order cookie is still present in the customer's browser. To prevent this, this change skips saving order details to the user if the user email and completed order email don't match. And it deletes the completed order cookie when the user logs out.

### Issues

- [ECOMMERCE-5392](https://jira.tools.weblinc.com/browse/ECOMMERCE-5392)

### Pull Requests

- [2893](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2893/overview)

### Commits

- [8fe4ae0e069bcb203cdbd85df9554a95f6ca4b5b](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/8fe4ae0e069bcb203cdbd85df9554a95f6ca4b5b)
- [6c6b184defac5c858384e18ded99f813166e4740](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/6c6b184defac5c858384e18ded99f813166e4740)
- [9342edc70685cd609b5de47ba0ccb6718af5fd6c](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/9342edc70685cd609b5de47ba0ccb6718af5fd6c)
- [32dd38e18c1615302986a742e708ba5830cfb8b0](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/32dd38e18c1615302986a742e708ba5830cfb8b0)

## Fixes Automatically Logging Out Customers

A scenario was discovered in which customers could automatically be logged out. This change modifies the Core authentication controller to fix the issue.

### Issues

- [ECOMMERCE-5344](https://jira.tools.weblinc.com/browse/ECOMMERCE-5344)

### Pull Requests

- [2907](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2907/overview)

### Commits

- [adb19825c3102fe5412103b503b2f6ccdaf17933](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/adb19825c3102fe5412103b503b2f6ccdaf17933)
- [126a698ae76a50875e34c37c70fb7753fc34e624](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/126a698ae76a50875e34c37c70fb7753fc34e624)
- [32dd38e18c1615302986a742e708ba5830cfb8b0](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/32dd38e18c1615302986a742e708ba5830cfb8b0)

## Displays a Warning When MongoDB "No Table Scan" is Set in Non-Test Environments

When running in test environments, Workarea sets MongoDB's [notablescan](https://docs.mongodb.com/manual/reference/parameters/#param.notablescan) parameter in order to detect unindexed queries. Some developers have reported this parameter turned on in non-test environments, presumably because a test run was interrupted before it could unset the parameter. This change adds a warning when notablescan is set in non-test environments. The warning message provides instructions to unset the parameter.

### Issues

- [ECOMMERCE-5389](https://jira.tools.weblinc.com/browse/ECOMMERCE-5389)

### Pull Requests

- [2919](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2919/overview)

### Commits

- [9d965126bac1b6d0baa00c9b59bca5d2c154b160](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/9d965126bac1b6d0baa00c9b59bca5d2c154b160)
- [b0f9b730b83c761c8a45139e7067c89c54de8c9e](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b0f9b730b83c761c8a45139e7067c89c54de8c9e)
- [32dd38e18c1615302986a742e708ba5830cfb8b0](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/32dd38e18c1615302986a742e708ba5830cfb8b0)

## Fixes Unclosed MongoDB Connections

MongoDB connections opened to set notablescan were not being closed. This change fixes the issue.

### Issues

- [ECOMMERCE-5429](https://jira.tools.weblinc.com/browse/ECOMMERCE-5429)

### Commits

- [2e00209e5494f09f3eda50b27f586cf4597b538e](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/2e00209e5494f09f3eda50b27f586cf4597b538e)
- [32dd38e18c1615302986a742e708ba5830cfb8b0](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/32dd38e18c1615302986a742e708ba5830cfb8b0)

## Fixes Content Editor Delay in Development

In multi-threaded development environments, the Admin content editor is often slow to load because it is waiting for iframes to load, but those iframes contain errors preventing them from loading. This change handles those errors and considers the iframes loaded so the content editor can be displayed more quickly. You can avoid these errors entirely by running a single-threaded server in development.

### Issues

- [ECOMMERCE-5385](https://jira.tools.weblinc.com/browse/ECOMMERCE-5385)

### Pull Requests

- [2920](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2920/overview)

### Commits

- [9e9eeab73804f9cd39af08fc9e543156d3a2fbfc](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/9e9eeab73804f9cd39af08fc9e543156d3a2fbfc)
- [56a8c1dd1f6940dd0f8333494438e062ea8d8dc4](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/56a8c1dd1f6940dd0f8333494438e062ea8d8dc4)
- [32dd38e18c1615302986a742e708ba5830cfb8b0](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/32dd38e18c1615302986a742e708ba5830cfb8b0)

