---
title: Workarea 3.1.28
excerpt: Patch release notes for Workarea 3.1.28.
---

# Workarea 3.1.28

Patch release notes for Workarea 3.1.28.

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


