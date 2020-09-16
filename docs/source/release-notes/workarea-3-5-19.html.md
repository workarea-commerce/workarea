---
title: Workarea 3.5.19
excerpt: Patch release notes for Workarea 3.5.19.
---

# Workarea 3.5.19

Patch release notes for Workarea 3.5.19.

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

## Make Order::Item#fulfilled_by? the canonical check of item's fulfillment

Methods such as #shipping? and #download? defined from available
fulfillment policies now call #fulfilled_by rather than being called
by it. This allows #fulfilled_by? to be modified to support more
complex scenarios like bundled items from kits.

### Pull Requests

- [499](https://github.com/workarea-commerce/workarea/pull/499)

## Update admin views for consistent display of inventory availability

This was done to improve the UX of inventory display across the admin and to help
with the new [product bundles plugin](https://github.com/workarea-commerce/workarea-product-bundles).

### Pull Requests

- [498](https://github.com/workarea-commerce/workarea/pull/498)

## Add config to allow defining a default tax code for shipping services

Previously, shipping services coming from a non-Workarea `ActiveShipping::Gateway`
had no way to attach a tax code so they can be taxed. This adds configuration to
enable a developer to provide a proc to determine the default tax rate or an admin
to specify this in the admin configuration.

### Pull Requests

- [504](https://github.com/workarea-commerce/workarea/pull/504)

## Fix incorrect tracking and metrics after impersonation

Not managing the email cookie and unintentional merging of metrics leads
to incorrect values in the admin.

### Pull Requests

- [503](https://github.com/workarea-commerce/workarea/pull/503)
