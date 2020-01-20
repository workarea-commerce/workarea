---
title: Workarea 3.5.4
excerpt: Patch release notes for Workarea 3.5.4.
---

# Workarea 3.5.4

Patch release notes for Workarea 3.5.4.

## Ignore Elements With Empty ID Values When Checking For Duplicates

`WORKAREA.duplicateID` was throwing a false positive exception when it
would find elements containing an id attribute with no value
specified. This behavior should be allowed, since empty ID values should
pose no issues for the developer.

### Issues

- [WORKAREA-184](https://workarea.atlassian.net/browse/WORKAREA-184)

### Pull Requests

- [317](https://github.com/workarea-commerce/workarea/pull/317)


## Add “edit footer” to handy links

Workarea now includes a shortcut in "Handy Links" to edit the page
footer.

### Issues

- [WORKAREA-145](https://workarea.atlassian.net/browse/WORKAREA-145)

### Pull Requests

- [312](https://github.com/workarea-commerce/workarea/pull/312)
- [293](https://github.com/workarea-commerce/workarea/pull/293)

## Fix Caching of Releasable Objects During Publish

Workarea now sorts release changesets prior to publishing and touches
all `Releasable` objects after publishing. This addresses an issue
wherein shoppers could navigate to the new category before the products
became active, causing blank category browse pages to end up in cache.

### Issues

- [WORKAREA-164](https://workarea.atlassian.net/browse/WORKAREA-164)

### Pull Requests

- [311](https://github.com/workarea-commerce/workarea/pull/311)
