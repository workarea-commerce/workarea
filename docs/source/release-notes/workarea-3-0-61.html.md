---
title: Workarea 3.0.61
excerpt: Patch release notes for Workarea 3.0.61.
---

# Workarea 3.0.61

Patch release notes for Workarea 3.0.61.

## Add Pagination to Shipping Services Admin Index

When an application has more than 100 shipping services in the database,
only the first 100 would show on the index. Additionally, such a large
query should be paginated. Render the `workarea/admin/shared/pagination`
partial at the bottom of the `<table>` containing all services and
paginate the collection of services that are queried for in the
controller.

### Issues

- [ECOMMERCE-6960](https://jira.tools.weblinc.com/browse/ECOMMERCE-6960)

### Pull Requests

- [4089](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4089/overview)


## Use Translations as a Fallback for Missing Name in Address Region Options

In the [countries](https://github.com/hexorx/countries) gem,
some subdivisions in a country (what Workarea calls "regions") do not
have a `:name` field associated with them. Instead of using `#name`,
return the value in the `#translations` hash matching the current
locale, falling back to `#name` if none can be found. This ensures that
the subdivisions of a country can be translated in the addresses region
select box.

### Issues

- [ECOMMERCE-6958](https://jira.tools.weblinc.com/browse/ECOMMERCE-6958)

### Pull Requests

- [4087](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4087/overview)
- [4084](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4084/overview)

