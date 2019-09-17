---
title: Workarea 3.4.16
excerpt: Patch release notes for Workarea 3.4.16.
---

# Workarea 3.4.16

Patch release notes for Workarea 3.4.16.

## Customize Search Queries That Return an Exact Match

It's currently possible to customize search queries that return an exact
match, but instead of seeing the customized results when you run the
query, you'll be redirected to the product page since the
`StorefrontSearch::ExactMatches` middleware stops further middleware
from running and sets a redirect to the product path. To resolve the issue,
Workarea will now ignore this middleware if a customization is present
on the search response.

Discovered by **Ryan Tulino** of **Syatt Media**. Thanks Ryan!

### Issues

- [ECOMMERCE-7063](https://jira.tools.weblinc.com/browse/ECOMMERCE-7063)

### Pull Requests

- [4177](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4177/overview)

## Prevent Empty Results In Trash

Remove a check for whether a given audit log entry is `#restorable?` in
on the **/admin/trash** page to prevent empty results clogging up the
pagination. Without this, admins will see blank pages if they delete
enough nav taxon/release records at the same time.

Additionally, due to `render_activity_entry` rescuing a template error
to return a blank string, results were still being seen in the trash when
a model that doesn't explicitly have an activity partial defined is encountered.
To resolve this issue, models that are tracked by `Mongoid::AuditLog`,
without an explicit activity partial defined will be rendered using a
generic partial, showing the class name and ID of the audited model, as
something to render in the listing so that pages of blank results aren't
shown.

### Issues

- [ECOMMERCE-7019](https://jira.tools.weblinc.com/browse/ECOMMERCE-7019)

### Pull Requests

- [4](https://github.com/workarea-commerce/workarea/pull/4)

## Use Current Host For Direct Upload CORS Headers

Direct uploads can fail locally if your `Workarea.config.host` is not
set to the domain you are currently using in the browser. To prevent
this, instead of reading from the configuration when ensuring CORS
headers on the S3 bucket, use the `ActionDispatch::Request` from the
controller to determine the correct URL for CORS in this instance.
Addresses a problem whereby changing the domain (either accidentally or
on-purpose) causes direct uploads to fail, since it can't create the
proper CORS headers needed to transmit files into the bucket directly.

### Issues

- [19](https://github.com/workarea-commerce/workarea/issues/19)

### Pull Requests

- [20](https://github.com/workarea-commerce/workarea/pull/20)
- [46](https://github.com/workarea-commerce/workarea/pull/46)

## Fix Randomly Failing System Test

Ensure test only asserts product details in `ProductSystemTest`.
Recently viewed products were being accidentally clicked on and thus the
incorrect information is being rendered to the screen, causing the test
to fail. Scope selectors to the product details component to avoid this.

### Issues

- [42](https://github.com/workarea-commerce/workarea/issues/42)

### Pull Requests

- [54](https://github.com/workarea-commerce/workarea/pull/54)

