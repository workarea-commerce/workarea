---
title: Workarea 3.4.40
excerpt: Patch release notes for Workarea 3.4.40.
---

# Workarea 3.4.40

Patch release notes for Workarea 3.4.40

## Remove CSV messaging for options fields

This removes the "Comma separated: just, like, this" messaging and
tooltip that explains more about comma-separated fields for filters and
details. Options do not have these same constraints, and this help
bubble just serves as a point of confusion for admins.

### Pull Requests

- [497](https://github.com/workarea-commerce/workarea/pull/497)

## Improve display of disabled toggles

When a toggle button is disabled, it should reflect that visually
instead of just looking like it should be functional.

### Pull Requests

- [507](https://github.com/workarea-commerce/workarea/pull/507)

## Fix editing product images in admin

When an image does not include an option, the edit page errors because
`#parameterize` cannot be called on `@image.option` since that is
returning `nil`. Additionally, the line of code in which this is called
is meant to set an ID attribute on the element for which an image is
rendered. There doesn't seem to be anything in our codebase that uses
this, and furthermore since there's no validation for unique options per
set of product images, this could cause a duplicate ID error in certain
scenarios. To resolve this, the ID attribute has been removed from this
`<img>` tag.

### Pull Requests

- [509](https://github.com/workarea-commerce/workarea/pull/509)
