---
title: Workarea 3.3.2
excerpt:  Conditionally displays the required indicator around the region field in storefront inputs when it is required, but not when region is either not required or not used in addresses. 
---

# Workarea 3.3.2

## Hide Region Field Text Required Indicator When Not Required

Conditionally displays the required indicator around the region field in storefront inputs when it is required, but not when region is either not required or not used in addresses.

### Issues

- [ECOMMERCE-6108](https://jira.tools.weblinc.com/browse/ECOMMERCE-6108)

### Pull Requests

- [3438](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3438/overview)

### Commits

- [b7e398b1cf117fb254a5cc00bfbf4765db382814](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b7e398b1cf117fb254a5cc00bfbf4765db382814)
- [9c4dd3f82b807513bc18b5b1572c41af20bba0e4](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/9c4dd3f82b807513bc18b5b1572c41af20bba0e4)

## Fix Wrong Action in Option Template Links

This was preventing proper selection of swatches on the storefront. We're now using details to fix XHR requests being incorrectly cached, and prevent duplicate content warnings when search engines crawl product detail pages.

### Issues

- [ECOMMERCE-6138](https://jira.tools.weblinc.com/browse/ECOMMERCE-6138)

### Pull Requests

- [3448](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3448/overview)

### Commits

- [814949805b3add7a547bccf20c26c5fd3c353a61](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/814949805b3add7a547bccf20c26c5fd3c353a61)

## Fix Option Set Templates Which Display Too Many Images

Use the primary image when no options are selected. Fixes a bug where by default a swatches product could attempt to render many more images than the design allows for.

### Issues

- [ECOMMERCE-6139](https://jira.tools.weblinc.com/browse/ECOMMERCE-6139)

### Pull Requests

- [3449](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3449)

### Commits

- [2181d3fc7cff378565b7fbc56348493d895a9767](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/2181d3fc7cff378565b7fbc56348493d895a9767)

## Add Helper For Setting Locales In Tests

Introduce two new helper methods, `set_locales` and `restore_locales`, which make it easier to manipulate locale configuration in tests. Fixes broken locale tests in host applications when certain plugins or app code changes locales in other tests.

### Issues

- [ECOMMERCE-6136](https://jira.tools.weblinc.com/browse/ECOMMERCE-6136)

### Pull Requests

- [3447](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3447/overview)

### Commits

- [0686a100a48e1e8ca67de22ef8578f073cdeb999](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/0686a100a48e1e8ca67de22ef8578f073cdeb999)

