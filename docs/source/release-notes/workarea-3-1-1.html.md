---
title: Workarea 3.1.1
excerpt: Presenting Admin analytics in UTC is confusing to administrators, so this change introduces a separate, configurable time zone to be used for time series data. Configure this time zone as appropriate for the retailer. The rest of the Admin remains in 
---

# Workarea 3.1.1

## Adds Configurable Time Zone for Admin Analytics

Presenting Admin analytics in UTC is confusing to administrators, so this change introduces a separate, configurable time zone to be used for time series data. **Configure this time zone as appropriate for the retailer**. The rest of the Admin remains in UTC. A future change will likely consolidate the entire Admin to a single configurable time zone.

### Issues

- [ECOMMERCE-5167](https://jira.tools.weblinc.com/browse/ECOMMERCE-5167)

### Pull Requests

- [2770](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2770/overview)

### Commits

- [979c14a9625b00eb09899debd92ba3b7ae324506](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/979c14a9625b00eb09899debd92ba3b7ae324506)
- [c6a59b4f3af4d057bab3a178b980a8f45421a91f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c6a59b4f3af4d057bab3a178b980a8f45421a91f)
- [a857790375fa4fecdf767701b93e356980296e9a](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/a857790375fa4fecdf767701b93e356980296e9a)

## Improves Search Spelling Corrections

Modifies query suggestions logic to improve search spelling corrections.

Modifies and adds configurable values affecting search suggestions.

### Issues

- [ECOMMERCE-5182](https://jira.tools.weblinc.com/browse/ECOMMERCE-5182)

### Pull Requests

- [2768](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2768/overview)

### Commits

- [f69000a88515304109324f903ec2bf40a1e1db8e](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/f69000a88515304109324f903ec2bf40a1e1db8e)
- [ac600cc3681f2119ed1941730ab253c6f8901447](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ac600cc3681f2119ed1941730ab253c6f8901447)

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

- [2765](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2765/overview)

### Commits

- [071113e64eb7efb08c25d63a180292247a3fb62a](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/071113e64eb7efb08c25d63a180292247a3fb62a)
- [ff9d92989dff470f53f66203a31d232a9c17893a](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ff9d92989dff470f53f66203a31d232a9c17893a)

## Fixes Exclusion of Application's Style Guide Partials from Style Guides

Fixes issue in the Core style guides helper that was causing the application's own style guide partials to be excluded from style guides.

### Issues

- [ECOMMERCE-5166](https://jira.tools.weblinc.com/browse/ECOMMERCE-5166)

### Pull Requests

- [2789](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2789/overview)

### Commits

- [dd3ffa69b1e2dacf66c4fe60acd5aa2860f333e2](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/dd3ffa69b1e2dacf66c4fe60acd5aa2860f333e2)

## Fixes Intermittent Failure of Admin Search Customizations Insights Test

Modifies Admin system test to prevent intermittent failures.

### Issues

- [ECOMMERCE-5218](https://jira.tools.weblinc.com/browse/ECOMMERCE-5218)

### Commits

- [2daceb7b5d03f73da2a745e2c49aa4404fb4fa80](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/2daceb7b5d03f73da2a745e2c49aa4404fb4fa80)

## Fixes Recurring Exception in Development Environment

Adds an extension to Rails when running in Development to avoid the need to manually restart the application under certain circumstances. Developers were experiencing an exception with the message `"unknown firstpos: NilClass"`.

### Issues

- [ECOMMERCE-5115](https://jira.tools.weblinc.com/browse/ECOMMERCE-5115)

### Pull Requests

- [2765](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2765/overview)

### Commits

- [e0270f49c599f9a917a00af80afb12904b81a407](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/e0270f49c599f9a917a00af80afb12904b81a407)

## Fixes Credit Card Tests Stubbing Active Merchant Responses

Improves credit card tests by using `ActiveMerchant::Response#authorization` instead of passing authorization through the params.

### Issues

- [ECOMMERCE-5229](https://jira.tools.weblinc.com/browse/ECOMMERCE-5229)

### Pull Requests

- [2799](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2799/overview)

### Commits

- [31ea5ff0318469f5483c16addcc01f55a46a6e41](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/31ea5ff0318469f5483c16addcc01f55a46a6e41)
- [c230eefb48bf73766beea024a22e03f86cc994c9](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c230eefb48bf73766beea024a22e03f86cc994c9)

