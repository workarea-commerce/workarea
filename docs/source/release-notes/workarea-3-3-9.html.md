---
title: Workarea 3.3.9
excerpt: Patch release notes for Workarea 3.3.9.
---

# Workarea 3.3.9

Patch release notes for Workarea 3.3.9.

## Configure WebConsole In Docker Generator For Development

The `workarea:docker` generator attempts to configure WebConsole for use in
Docker, by whitelisting certain IPs, but this gem is not loaded (out of
the box) in testing or production, resulting in immediate failures.
Workarea will now only apply the WebConsole configuration in the
development environment, since that is the only place that WebConsole
should be running.

### Issues

- [ECOMMERCE-6360](https://jira.tools.weblinc.com/browse/ECOMMERCE-6360)

### Pull Requests

- [3590](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3590/overview)

### Commits

- [031db0a13f43fe344d20b1230df1d5b94df79bc1](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/031db0a13f43fe344d20b1230df1d5b94df79bc1)


## Correct Unit Price When Some Discounts Are Applied

The `BuySomeGetSome` discount type can cause issues with calculating unit
price at the price adjustment level. To alleviate these issues, unit
price for an item is calculated as the sum of all price adjustments
divided by the item's quantity, instead of each price adjustment
calculating its own unit price and adding them up. This allows the
calculation of other discount values to be accurate if `BuySomeGetSome`
discounts the amount of an entire unit.

### Issues

- [ECOMMERCE-6242](https://jira.tools.weblinc.com/browse/ECOMMERCE-6242)

### Pull Requests

- [3569](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3569/overview)

### Commits

- [80775bd8e773710d219a6d44c6e6e483b50e1585](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/80775bd8e773710d219a6d44c6e6e483b50e1585)


## Sort Product Images By Position In Option Set Templates

The `option_selects` and `option_thumbnails` product templates will now
respect the `:position` field of each product image, and sort by that value
before filtering out images based on the selected SKU or primary image.

### Issues

- [ECOMMERCE-6326](https://jira.tools.weblinc.com/browse/ECOMMERCE-6326)

### Pull Requests

- [3577](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3577/overview)

### Commits

- [1c1436f499e97d9392d9dfe00b0b447f7a99c606](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/1c1436f499e97d9392d9dfe00b0b447f7a99c606)


## Fix Search Suggestions With Same Query ID

Searches that have the same `QueryString` ID will have the same
results, and sometimes Workarea suggested searches that boiled down to
the same query ID. These searches are now omitted before being rendered
to the user as suggestions.

### Issues

- [ECOMMERCE-6362](https://jira.tools.weblinc.com/browse/ECOMMERCE-6362)

### Pull Requests

- [3592](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3592/overview)

### Commits

- [f21b5227daa11f5fd440c06c43f20720e3f78d9f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/f21b5227daa11f5fd440c06c43f20720e3f78d9f)


