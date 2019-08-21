---
title: Workarea 3.0.15
excerpt: Presenting Admin analytics in UTC is confusing to administrators, so this change introduces a separate, configurable time zone to be used for time series data. Configure this time zone as appropriate for the retailer. The rest of the Admin remains in 
---

# Workarea 3.0.15

## Adds Configurable Time Zone for Admin Analytics

Presenting Admin analytics in UTC is confusing to administrators, so this change introduces a separate, configurable time zone to be used for time series data. **Configure this time zone as appropriate for the retailer**. The rest of the Admin remains in UTC. A future change will likely consolidate the entire Admin to a single configurable time zone.

### Issues

- [ECOMMERCE-5167](https://jira.tools.weblinc.com/browse/ECOMMERCE-5167)

### Pull Requests

- [2770](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2770/overview)

### Commits

- [979c14a9625b00eb09899debd92ba3b7ae324506](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/979c14a9625b00eb09899debd92ba3b7ae324506)
- [c6a59b4f3af4d057bab3a178b980a8f45421a91f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c6a59b4f3af4d057bab3a178b980a8f45421a91f)
- [6b59446d004341882f087810146c0151f1be7586](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/6b59446d004341882f087810146c0151f1be7586)

## Improves Search Spelling Corrections

Modifies query suggestions logic to improve search spelling corrections.

Modifies and adds configurable values affecting search suggestions.

### Issues

- [ECOMMERCE-5182](https://jira.tools.weblinc.com/browse/ECOMMERCE-5182)

### Pull Requests

- [2798](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2798/overview)

### Commits

- [c935ea9f2d30e9f572e26e0b88af27d02198c00e](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c935ea9f2d30e9f572e26e0b88af27d02198c00e)
- [81b3a9cbb3a55d54fa940f3cf9a4edd11bc1f961](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/81b3a9cbb3a55d54fa940f3cf9a4edd11bc1f961)

## Modifies JavaScript URL Parsing to Support Parameter Arrays

Changes the behavior of `WEBLINC.url.parse()` to support parsing arrays in the query string.

### Issues

- [ECOMMERCE-5206](https://jira.tools.weblinc.com/browse/ECOMMERCE-5206)

### Pull Requests

- [2772](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2772/overview)

### Commits

- [1bc646cbc6f2b1300baa1ba8ef65dec86ce38cf3](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/1bc646cbc6f2b1300baa1ba8ef65dec86ce38cf3)
- [cddbee4455bd749fbcc003c7f4a3be908a2e5bcf](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/cddbee4455bd749fbcc003c7f4a3be908a2e5bcf)

## Fixes Taxon Navigable Slug Not Updating with Change of Navigable Slug

Fixes `Workarea::Navigable#update_taxon_slug` to ensure changes to a navigable's slug are applied to the corresponding taxon.

### Issues

- [ECOMMERCE-5224](https://jira.tools.weblinc.com/browse/ECOMMERCE-5224)

### Pull Requests

- [2793](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2793/overview)

### Commits

- [faf62712a42b7d597ed4617d755266e2a5ed7115](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/faf62712a42b7d597ed4617d755266e2a5ed7115)
- [8756987660f1fb937a6df6ce86d28774efe3632b](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/8756987660f1fb937a6df6ce86d28774efe3632b)

## Fixes Exclusion of Application's Style Guide Partials from Style Guides

Fixes issue in the Core style guides helper that was causing the application's own style guide partials to be excluded from style guides.

### Issues

- [ECOMMERCE-5166](https://jira.tools.weblinc.com/browse/ECOMMERCE-5166)

### Pull Requests

- [2789](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2789/overview)

### Commits

- [b1588e2c4e54352c556d5b18d76c4fc71effa726](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b1588e2c4e54352c556d5b18d76c4fc71effa726)
- [f3c104a454c8a5cd6218e6e97a16f17c9dd08869](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/f3c104a454c8a5cd6218e6e97a16f17c9dd08869)

## Fixes Intermittent Failure of Admin Search Customizations Insights Test

Modifies Admin system test to prevent intermittent failures.

### Issues

- [ECOMMERCE-5218](https://jira.tools.weblinc.com/browse/ECOMMERCE-5218)

### Commits

- [1645551d71d007f40e50aa813fa139bfb3ccc165](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/1645551d71d007f40e50aa813fa139bfb3ccc165)

