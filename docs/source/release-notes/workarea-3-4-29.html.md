---
title: Workarea 3.4.29
excerpt: Patch release notes for Workarea 3.4.29.
---

# Workarea 3.4.29

Patch release notes for Workarea 3.4.29.

## Fix Filtered Products Link Location in Admin

When `.json` requests are made against the admin, the
`#track_index_filters` callback was previously saving off the full path,
resulting in issues with the back-linking on the admin UI. To resolve
this, Workarea no longer considers `.json` requests on the index page to
be a valid `session[:last_index_path]`.

**More Info:** https://discourse.workarea.com/t/broken-filtered-products-link/1796

### Pull Requests

- [383](https://github.com/workarea-commerce/workarea/pull/383)


## Limit Jump-To Results Per Result Type

Improve the admin autocomplete by limiting the jump-to results per type.
This allows the user to see a more diverse set of results instead of
being overwhelmed by many matches in the top types.

### Pull Requests

- [387](https://github.com/workarea-commerce/workarea/pull/387)

