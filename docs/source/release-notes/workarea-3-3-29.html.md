---
title: Workarea 3.3.29
excerpt: Patch release notes for Workarea 3.3.29.
---

# Workarea 3.3.29

Patch release notes for Workarea 3.3.29.

## Stop Premailer From Automatically Combining CSS Rules

When possible Premailer will combine separated properties, like
`background-image`, `background-position`, etc, into one, single
property. This causes issues in the Yahoo Mail interface, as well as
others. Workarea now prevents this behavior so developers have more
control over their email templates.

### Issues

- [ECOMMERCE-6941](https://jira.tools.weblinc.com/browse/ECOMMERCE-6941)

### Pull Requests

- [4086](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4086/overview)


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

