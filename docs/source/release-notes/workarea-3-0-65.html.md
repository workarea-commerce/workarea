---
title: Workarea 3.0.65
excerpt: Patch release notes for Workarea 3.0.65.
---

# Workarea 3.0.65

Patch release notes for Workarea 3.0.65.

## Display Relevant Flash Message When No Shipping Options Are Available

Improve the user experience when checkout cannot complete due to the
site having no available shipping options for the user's shipping
address.

### Issues

- [ECOMMERCE-6992](https://jira.tools.weblinc.com/browse/ECOMMERCE-6992)

### Pull Requests

- [4166](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4166/overview)

## Disallow Negative Prices in Seed Data

It was formerly possible to generate a `Pricing::Price` that had a
negative value in seeds. The `ProductsSeeds#perform` method now protects
against this.

### Issues

- [ECOMMERCE-7062](https://jira.tools.weblinc.com/browse/ECOMMERCE-7062)

### Pull Requests

- [4167](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4167/overview)

