---
title: Workarea 3.1.17
excerpt:  When the region select on an addresses form is auto-selected, due to the selection of a country, the addresses form will not be submittable because the actual value of the region select is no longer available. This is due to the way we hide the optio
---

# Workarea 3.1.17

## Fix validation error when region select is auto-filled

When the region select on an addresses form is auto-selected, due to the selection of a country, the addresses form will not be submittable because the actual value of the region select is no longer available. This is due to the way we hide the `option` tags inside our region select that don't pertain to the current country. We're now removing all `option` tags in the region select that don't pertain to the current country, which prevents the validation error from displaying unnecessarily in checkout.

Solved by **Darielle Davis** on the LimeCrime project. We ported her code into v3.x so all future projects can benefit. Thanks Dari!

### Issues

- [ECOMMERCE-5640](https://jira.tools.weblinc.com/browse/ECOMMERCE-5640)

### Pull Requests

- [3252](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3252)

### Commits

- [1c90074739280a977f198501f8408eb1e0e997e0](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/1c90074739280a977f198501f8408eb1e0e997e0)

## Fix repeating query when loading featured products

When loading featured products, we were running the same query each time we looped over the collection of featured products to return them in the same order of insertion. By converting to an array before sorting each featured product and wrapping the models in view models, we're preventing execution of the query unnecessarily.

### Issues

- [ECOMMERCE-5905](https://jira.tools.weblinc.com/browse/ECOMMERCE-5905)

### Pull Requests

- [3255](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3255)

### Commits

- [bcd57daa19b92fe4eb5c0924fe76d15b0cafde31](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/bcd57daa19b92fe4eb5c0924fe76d15b0cafde31)

## Fix error in auto-expiring Redis client for Geocoder

Since we cache Geocoder responses in Redis, a recent change to the underlying Redis ruby client forced us to implement our own `#[]` and `#[]=` methods on the cache store we're using for Geocoder. Due to an issue with the order of arguments in the `Redis#setex` method, errors began occurring after geocoded data was added to the application. The order of arguments has been fixed, and newly cached Geocoder responses should be properly formatted and evicted at the right time.

Discovered by **John Varady**. Thanks John!

### Issues

- [ECOMMERCE-5927](https://jira.tools.weblinc.com/browse/ECOMMERCE-5927)

### Pull Requests

- [3265](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3265)

### Commits

- [dd9f7f0c473872b14eceba046aa47cfbd5adcbd3](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/dd9f7f0c473872b14eceba046aa47cfbd5adcbd3)

## Fix featured product changes on a category potentially causing request timeouts

Editing large sets of featured products caused request timeouts due to inlined `Sidekiq::Callbacks`, which could initiate the `Workarea::IndexCategoryChanges` many different times. We're now ensuring that all indexing jobs occur in the background so that this doesn't happen.

### Issues

- [ECOMMERCE-5850](https://jira.tools.weblinc.com/browse/ECOMMERCE-5850)

### Pull Requests

- [3237](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3237)

### Commits

- [c63358fb2496abe0bc930abbd1a265ddf1ccb132](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c63358fb2496abe0bc930abbd1a265ddf1ccb132)

## Fix PingHomeBaseTest adding extra plugins

Testing `Workarea::PingHomeBase` causes extra plugins to appear in the `Workarea::Plugin.installed` list. Exclude these test plugins from the list so we're not making additional passes for things like decorators, assets, Ruby code, and other hot-loaded items.

### Issues

- [ECOMMERCE-5522](https://jira.tools.weblinc.com/browse/ECOMMERCE-5522)

### Pull Requests

- [3244](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3244)

### Commits

- [ae6bc6e33db283dc946dd66625bc9cebc2244f5e](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ae6bc6e33db283dc946dd66625bc9cebc2244f5e)

## Handle malformed facet param on browse/search

When URLs with params like `?color=Red` come through and additional filters are "shoveled" into the URL query param, the new URL would look like `?color=RedBlue` because the new selection was just shoveled onto the param if it already existed. We're now ensuring that the param is an Array before generating the URL, so filter params will always come in like e.g. `?color[]=Red&color[]=Blue`.

Discovered by **Jordan Stewart**. Thanks Jordan!

### Issues

- [ECOMMERCE-5839](https://jira.tools.weblinc.com/browse/ECOMMERCE-5839)

### Pull Requests

- [3227](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3227)

### Commits

- [958db040721c130412a6d64a5af22fd489e42181](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/958db040721c130412a6d64a5af22fd489e42181)

## Make return values of WORKAREA.currentUser more consistent

Developers interchangeably use the `refresh()` and `gettingUserData` strategies for getting user data from the system, but these two methods differ in their return value. Make the `WORKAREA.currentUser.refresh()` method also return the `WORKAREA.currentUser.gettingUserData` promise that it defines, or is already defined.

### Issues

- [ECOMMERCE-5928](https://jira.tools.weblinc.com/browse/ECOMMERCE-5928)

### Pull Requests

- [3266](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3266)

### Commits

- [27384328f7b52f2814b8f1679dc501451f570b6c](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/27384328f7b52f2814b8f1679dc501451f570b6c)

## Prevent unsaved changes warning on taxonomy edit page when nothing has changed

Navigating away from the taxonomy edit form would produce an unsaved changes warning because of how select2 inserts its data after the form has rendered, and before we've checked the form to see if anything changed. Resolved this to ignore unsaved changes when select2 elements are initialized.

### Issues

- [ECOMMERCE-5219](https://jira.tools.weblinc.com/browse/ECOMMERCE-5219)

### Pull Requests

- [3267](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3267)

### Commits

- [1a2b7a84924b6a3ed44d0460d0cadd8613985c9f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/1a2b7a84924b6a3ed44d0460d0cadd8613985c9f)

