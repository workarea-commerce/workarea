---
title: Workarea 3.0.18
excerpt: Updates the platform's sidekiq-cron dependency to '~> 0.6.3' to address reports of scheduled jobs not running.
---

# Workarea 3.0.18

## Updates Sidekiq Cron Dependency

Updates the platform's [sidekiq-cron](https://rubygems.org/gems/sidekiq-cron) dependency to `'~> 0.6.3'` to address reports of scheduled jobs not running.

### Issues

- [ECOMMERCE-5358](https://jira.tools.weblinc.com/browse/ECOMMERCE-5358)

### Pull Requests

- [2880](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2880/overview)

### Commits

- [5baf4336baa6aa8fe4f9609ba7a854ae3bca700f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/5baf4336baa6aa8fe4f9609ba7a854ae3bca700f)
- [33401afc59ab97ebc61b3526891db73029e785bd](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/33401afc59ab97ebc61b3526891db73029e785bd)

## Removes HTTP Caching of Storefront 404 Pages

Modifies the Storefront errors controller to prevent 404 pages from being HTTP cached.

### Issues

- [ECOMMERCE-5359](https://jira.tools.weblinc.com/browse/ECOMMERCE-5359)

### Pull Requests

- [2876](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2876/overview)

### Commits

- [f449d56c98cb7d0823b079040ac6da70992985db](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/f449d56c98cb7d0823b079040ac6da70992985db)
- [c85f62871ad132961787a651ce3a093836686af2](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c85f62871ad132961787a651ce3a093836686af2)

## Fixes Product Rules Search Query for Multiple Categories

When querying for products matching a product rule whose value is a list of categories, the query should return the _union_ of those categories, that is, the list of products in _any_ of the specified categories. The query was incorrectly returning the _intersection_ (i.e. the products common to _all_ the categories specified in the rule).

This change modifies the product rules search query to return the correct products.

### Issues

- [ECOMMERCE-5263](https://jira.tools.weblinc.com/browse/ECOMMERCE-5263)

### Pull Requests

- [2836](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2836/overview)

### Commits

- [45b9f0a61efe74a65146b3316652af6781c355f6](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/45b9f0a61efe74a65146b3316652af6781c355f6)
- [96510dbedda745982b138f844052afc1dfccdbb6](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/96510dbedda745982b138f844052afc1dfccdbb6)

## Fixes Display of Admin Filter Dropdown

Fixes z-index of Admin browsing control filter dropdowns, which were displaying incorrectly

### Issues

- [ECOMMERCE-5268](https://jira.tools.weblinc.com/browse/ECOMMERCE-5268)

### Pull Requests

- [2859](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2859/overview)

### Commits

- [7c396c6a275e94beb7f109dd5a7623a5ff2bb75d](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/7c396c6a275e94beb7f109dd5a7623a5ff2bb75d)
- [50a6655af3ed38218cd2e47872d3c75a95726b17](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/50a6655af3ed38218cd2e47872d3c75a95726b17)

## Fixes Admin Help Search Margin

Modifies the Admin search form component to fix the bottom margin of the Admin help search form.

### Issues

- [ECOMMERCE-5388](https://jira.tools.weblinc.com/browse/ECOMMERCE-5388)

### Commits

- [f1a235507e297de2e725fb511d296d1c00f1629b](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/f1a235507e297de2e725fb511d296d1c00f1629b)

## Fixes Button Content Block SVG

Modifies the button content block SVG file in the Admin to fix the fill color, which was inconsistent with other content block icons.

### Issues

- [ECOMMERCE-5322](https://jira.tools.weblinc.com/browse/ECOMMERCE-5322)

### Pull Requests

- [2875](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2875/overview)

### Commits

- [2e8f03024b4dcf1bcb4ef4d059ddfe8b6b1fc799](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/2e8f03024b4dcf1bcb4ef4d059ddfe8b6b1fc799)
- [f2d9d2be5d0af3d1a87ff6df8464e8cbf06f4277](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/f2d9d2be5d0af3d1a87ff6df8464e8cbf06f4277)

## Adds Link Color Modifier to SVG Icon Component in Admin

Adds the _link-color_ modifier to the _svg-icon_ component in the Admin.

### Issues

- [ECOMMERCE-5375](https://jira.tools.weblinc.com/browse/ECOMMERCE-5375)

### Pull Requests

- [2883](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2883/overview)

### Commits

- [0f72de885f69b02d5eb0e59522b5b0eed7a0f485](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/0f72de885f69b02d5eb0e59522b5b0eed7a0f485)
- [bcc9fa9b18cef083f9cdd5c37deed8f1a4ac4ebd](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/bcc9fa9b18cef083f9cdd5c37deed8f1a4ac4ebd)

