---
title: Workarea 3.4.17
excerpt: Patch release notes for Workarea 3.4.19.
---

# Workarea 3.4.19

Patch release notes for Workarea 3.4.19.

## Lock Down Sprockets to v3.7.2

Sprockets v4.0 was released on 10/8/2019, which removed the
`.register_engine` method that is depended on by many extensions to
Sprockets at the current moment. Lock down Sprockets to v3.7.2 to avoid
these issues, which will show up when the app is loaded or tests are
run.

### Pull Requests

- [152](https://github.com/workarea-commerce/workarea/pull/152)

### Issues

- [WORKAREA-18](https://workarea.atlassian.net/browse/WORKAREA-18)

## `_id` Suffix Omitted From Customized Fields

When adding a customized field to a `Customizations` class that ends in
`_id`, Workarea was previously stripping this suffix from the computed
instance variable name that is converted into snake case from any kind
of input. This causes issues because the data doesn't appear to be
making it into customizations, but is really there under a different
instance variable name. To resolve the issue, Workarea now detects
whether a variable is already using snake case and leaves it
alone...only providing transformations for variable names that need it.

### Pull Requests

- [146](https://github.com/workarea-commerce/workarea/pull/146)

### Issues

- [144](https://github.com/workarea-commerce/workarea/issues/144)

## Fix Tests for Admin Toolbar

The admin toolbar is loaded within an `<iframe>`, which makes Capybara unable
to determine when it's been loaded. As a result, Capybara attempts to perform
actions on the element when it has not fully loaded, which results in failing tests
on CI. While there doesn't seem to be a definitive solution to this issue, a
`sleep` has been added prior to testing markup in the `<iframe>` in order to get
tests passing for now. In the future, the admin toolbar will no longer be loaded
within an `<iframe>`, which will avoid this problem by v3.6.

### Pull Requests

- [136](https://github.com/workarea-commerce/workarea/pull/136)

## Lock Down Faraday to v0.15.x

Faraday released breaking changes in **v0.16.0** that were not properly supported
by our required version of the Elasticsearch gem. This caused builds to fail with
strange Faraday errors and an inability to connect to the server. Locking down
Faraday to the latest **v0.15** version has resolved the issues in builds.

### Pull Requests

- [134](https://github.com/workarea-commerce/workarea/pull/134)

## Improve Order of Changesets in Timeline UI

A UX improvement to how changesets are ordered in the timeline. They will now
be rendered in the following order:

1. Unscheduled changesets
2. Scheduled changesets, ordered by the release's publish date,
descending
3. Today (if applicable)
4. Historical changesets

### Pull Requests

- [126](https://github.com/workarea-commerce/workarea/pull/126)

## Fix Self-Referential Category Product Rules

Adding the same ID to a category product rule matching the product list
that contains it results in some wonky results coming back. This was
originally diagnosed as an issue when combining category rules, but in
reality, it has to do with an admin mis-using the product rules
interface and perhaps accidentally using the category's own ID in a
product rule. To prevent this from happening, Workarea now cleans the
current `product_list.id` from the value if a category rule is created or
updated.

### Pull Requests

- [110](https://github.com/workarea-commerce/workarea/pull/110)

### Issues

- [52](https://github.com/workarea-commerce/workarea/pull/52)

## Fix missing aspect ratio magic attribute

This magic attribute doesn't need to be calculated, it's the inverse of 
the aspect ratio we already have. Relying on the magic attributes for 
this would require re-saving each model instance.

### Pull Requests

- [170](https://github.com/workarea-commerce/workarea/pull/170)
