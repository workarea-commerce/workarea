---
title: Workarea 3.2.34
excerpt: Patch release notes for Workarea 3.2.34.
---

# Workarea 3.2.34

Patch release notes for Workarea 3.2.34.

## Fix Error When Viewing Release Show Page in Admin

When viewing a Release in admin, an error can occur if a `Releasable`
model becomes nil between the time the release is being viewed and when
it was originally created/planned. Workarea now ensures the release can
always be viewed in the admin by not rendering any changesets that can't
be drawn back to a releasable model currently in the database.

### Issues

- [ECOMMERCE-6904](https://jira.tools.weblinc.com/browse/ECOMMERCE-6904)

### Pull Requests

- [4015](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4015/overview)

## Disable Slug Input On Unreleased Pages

Set `disabled: true` on slug inputs when making changes within a
release, and add help text to explain why it cannot be edited. Since slugs
cannot be changed within a release, having this as a field a user can
type into created a confusing experience.

### Issues

- [ECOMMERCE-6805](https://jira.tools.weblinc.com/browse/ECOMMERCE-6805)

### Pull Requests

- [3964](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3964/overview)

## Add `workarea:services:clean` for Removing Services Data

This task runs `docker-compose down -v`, which will remove volumes
associated with the application. It's useful when transitioning between
v3.3 and v3.4, so the Mongo data doesn't become corrupted, but should
only be used if you're OK with your data getting deleted.

Additionally, an environment variable called `$COMPOSE_ARGUMENTS` has been introduced to provide a means of passing command-line arguments to the `docker-compose` commands that are run using these tasks. For example:

    COMPOSE_ARGUMENTS="--remove-orphans" rails workarea:services:up

### Issues

- [ECOMMERCE-6874](https://jira.tools.weblinc.com/browse/ECOMMERCE-6874)

### Pull Requests

- [3998](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3998/overview)

## Validate Product Rule Lucene Query Syntax

When invalid Lucene queries are saved into product rules, an error would
occur when attempting to browse the category because the query was never
checked for valid syntax. As part of the validation process for product
rules, run a `Search::CategoryBrowse` query for the rule being created
or edited, and add an error to the model if Elasticsearch responds with
a server error (5xx) HTTP status. This prevents the rule from being saved
on the product list in the first place.


### Issues

- [ECOMMERCE-6849](https://jira.tools.weblinc.com/browse/ECOMMERCE-6849)

### Pull Requests

- [3977](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3977/overview)

## Add MongoDB Indexes For Default Scopes Without Corresponding Indexes

Since `noTableScan` enforces that all queries to MongoDB need to have
corresponding indexes, it was previously possible to receive an error
when attempting query something seemingly simple, such as
`User::AdminBookmark.all`. Add indexes for any models who have a
`default_scope`, but no corresponding index for the query that scope
generates. This may not always be caught by the base test suite, but
can affect things like console usage, rake tasks, decorations, etc.

### Issues

- [ECOMMERCE-6876](https://jira.tools.weblinc.com/browse/ECOMMERCE-6876)

### Pull Requests

- [4003](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4003/overview)

## Disable Permissions Management When User is a Super-Admin

When a user has super-admin privileges in admin, it was previously
possible to attempt removing admin access as well as access to areas of
the admin, but these values would just get re-set after the form
completed anyway. Workarea now sets all checkboxes on the permissions
page to `disabled`, and renders a warning message above the form stating
that you cannot change permissions for users who are super-admins. It
also instructs the admin how to disable super-admin for a user in order
for this page to function normally.


### Issues

- [ECOMMERCE-6902](https://jira.tools.weblinc.com/browse/ECOMMERCE-6902)

### Pull Requests

- [4011](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4011/overview)

## Fix Issue With Sale Price Creation

When adding/editing prices for a SKU in the admin interface, the
messaging underneath the field says `Sale Price (defaults to regular)`,
but when left blank the Sale Price will be saved as **$0.00**. This is
due to the use of a numeric field type on the `<input>` tag. To resolve
this, Workarea now converts this value to `nil` in the controller, so
that the price will be added into the backend with an empty value for
the `:sale` field. When the sale field is blank, the pricing system will
default to using the regular price in all scenarios.

Solved by **Jeremie Ges**. Thanks Jeremie!

### Issues

- [ECOMMERCE-6833](https://jira.tools.weblinc.com/browse/ECOMMERCE-6833)

### Pull Requests

- [4005](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4005/overview)

## Fix Test Failing During Daylight Savings Time

Testing `Analytics::User.orders_per` during daylight savings time
results in the test failing because of the hour difference between the
current time and the duration of `7.days.ago` in the test. Ensure that
this assertion always runs on a date that isn't in DST so the test won't
fail on the day DST changes next year.

### Issues

- [ECOMMERCE-6731](https://jira.tools.weblinc.com/browse/ECOMMERCE-6731)

### Pull Requests

- [4018](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4018/overview)

