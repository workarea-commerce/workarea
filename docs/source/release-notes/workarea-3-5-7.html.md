---
title: Workarea 3.5.7
excerpt: Patch release notes for Workarea 3.5.7.
---

# Workarea 3.5.7

Patch release notes for Workarea 3.5.7.

## Add Validation For Date Time Pickers

Ensure the hidden input storing the value for the dateTimePicker is
`:required`, which prevents the form from saving. This value is also
passed down into the template UI created by the JS module in order to
make sure the user gets some visual feedback. Add the required attribute
to the `dateTimePicker` on adding custom events in the timeline report.

### Pull Requests

- [392](https://github.com/workarea-commerce/workarea/pull/392)


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

