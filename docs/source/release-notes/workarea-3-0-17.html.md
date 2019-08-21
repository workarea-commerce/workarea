---
title: Workarea 3.0.17
excerpt: Adds a helper to sanitize config values displayed on the Admin settings dashboard. Removes complex data types from the output to clean up the display and prevent revealing secrets.
---

# Workarea 3.0.17

## Removes Complex Values from Admin Settings Dashboard

Adds a helper to sanitize config values displayed on the Admin settings dashboard. Removes complex data types from the output to clean up the display and prevent revealing secrets.

### Issues

- [ECOMMERCE-5238](https://jira.tools.weblinc.com/browse/ECOMMERCE-5238)

### Commits

- [bbfb5acfef475290d1a3e63955c8d27c7ed9af7c](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/bbfb5acfef475290d1a3e63955c8d27c7ed9af7c)

## Excludes CSRF Tokens from Cached Requests

Excludes CSRF tokens from response bodies for HTTP cached requests because they aren't useful and they're causing automated tools to incorrectly report applications as vulnerable to a breach attack.

### Issues

- [ECOMMERCE-5250](https://jira.tools.weblinc.com/browse/ECOMMERCE-5250)

### Pull Requests

- [2813](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2813/overview)

### Commits

- [c6decbf58b648b7f122a5238df53b8fe4b464349](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c6decbf58b648b7f122a5238df53b8fe4b464349)
- [882cb7d919c2e906d6325c2185c89fd4a92a8ebc](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/882cb7d919c2e906d6325c2185c89fd4a92a8ebc)

## Fixes Finding Products by Blank Sku

Modifies `Workarea::Catalog.find_by_sku(sku)` to return `nil` when `sku` is blank, preventing unexpected results.

### Issues

- [ECOMMERCE-5046](https://jira.tools.weblinc.com/browse/ECOMMERCE-5046)

### Pull Requests

- [2852](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2852/overview)

### Commits

- [dcdff1d4eb0f2d46ce3fe28dc3557d28a0ce1c17](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/dcdff1d4eb0f2d46ce3fe28dc3557d28a0ce1c17)
- [7498748d32a2fee6388d7550f842df4520c44184](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/7498748d32a2fee6388d7550f842df4520c44184)

## Fixes Selects Overflowing Viewport in Storefront

Changes width of _select_ elements in the Storefront to avoid overflowing container on narrow screens.

### Issues

- [ECOMMERCE-5190](https://jira.tools.weblinc.com/browse/ECOMMERCE-5190)

### Pull Requests

- [2829](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2829/overview)

### Commits

- [74506df03612988892e0a8f5ed27ce62386de1d3](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/74506df03612988892e0a8f5ed27ce62386de1d3)
- [186687e2c4aa3f1d1142fa74a9fcb4b1eda0ecd7](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/186687e2c4aa3f1d1142fa74a9fcb4b1eda0ecd7)

## Fixes Display of Internationalized Text Boxes in Admin

Increases width of internationalized _text-box_ components in Admin to fix truncated display of their values.

### Issues

- [ECOMMERCE-5192](https://jira.tools.weblinc.com/browse/ECOMMERCE-5192)

### Pull Requests

- [2810](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2810/overview)

### Commits

- [7a8262e927caaee2b0ffadb877cf54f4673bdb0f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/7a8262e927caaee2b0ffadb877cf54f4673bdb0f)
- [9c89a86a06a179e1930dc9a426f48f8c3c77080c](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/9c89a86a06a179e1930dc9a426f48f8c3c77080c)

## Fixes Quotes within Admin Releases Select

Fixes display of the Admin releases select when its options include quote characters.

### Issues

- [ECOMMERCE-4445](https://jira.tools.weblinc.com/browse/ECOMMERCE-4445)

### Pull Requests

- [2610](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2610/overview)

### Commits

- [70772553b5975aef428bc777543fd5f61cc07cca](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/70772553b5975aef428bc777543fd5f61cc07cca)
- [c3cf82fa2b8f038b50f09e31a3cedc867a4cceb5](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c3cf82fa2b8f038b50f09e31a3cedc867a4cceb5)

## Improves Admin New Release UI

Adds client side validation to and fixes spacing of new release form in Admin. Backported from changes that will be released in Workarea 3.2.

### Issues

- [ECOMMERCE-5271](https://jira.tools.weblinc.com/browse/ECOMMERCE-5271)

### Pull Requests

- [2832](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2832/overview)
- [2847](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2847/overview)

### Commits

- [887a02fdd2431dd88ba538be8cb6c34f813eb486](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/887a02fdd2431dd88ba538be8cb6c34f813eb486)
- [591e9c5f182359c9b266a973a3a011d8744ff487](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/591e9c5f182359c9b266a973a3a011d8744ff487)
- [66e13d1e146405885d752fb700e091d9d8eba2e0](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/66e13d1e146405885d752fb700e091d9d8eba2e0)
- [9c87b19247d3d59e6097fbb500dec0bd60985232](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/9c87b19247d3d59e6097fbb500dec0bd60985232)

## Adds Dragonfly S3 Data Store to App Template

Adds [dragonfly-s3\_data\_store](https://rubygems.org/gems/dragonfly-s3_data_store) as an application dependency for new apps via the app template since most production applications need this dependency.

### Issues

- [ECOMMERCE-5269](https://jira.tools.weblinc.com/browse/ECOMMERCE-5269)

### Pull Requests

- [2838](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2838/overview)

### Commits

- [bebb34554dd83ba605dd4adf8f2e986c311f1d63](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/bebb34554dd83ba605dd4adf8f2e986c311f1d63)
- [8ab83930c7e3201cb3b67af033c277ce256c086d](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/8ab83930c7e3201cb3b67af033c277ce256c086d)

