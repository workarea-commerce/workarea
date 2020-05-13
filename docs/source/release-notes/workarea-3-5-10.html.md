---
title: Workarea 3.5.10
excerpt: Patch release notes for Workarea 3.5.10.
---

# Workarea 3.5.10

Patch release notes for Workarea 3.5.9.

## Fix bugs with per_page used in page calculation for search queries

Even though this shouldn't come from the outside world, it's easy and best to ensure per_page is always a valid number.

### Pull Requests

- [420](https://github.com/workarea-commerce/workarea/pull/420)

## Skip localized activeness test when localized active fields are off

### Pull Requests

- [422](https://github.com/workarea-commerce/workarea/pull/422)

## Fix accepting per_page param from outside world

Page size is the most important factor in performance for browse pages, so we don't want these exposed to the outside world out-of-the-box.

### Pull Requests

- [420](https://github.com/workarea-commerce/workarea/pull/420)

## Corrected no_available_shipping_options translation typo

### Pull Requests

- [418](https://github.com/workarea-commerce/workarea/pull/418)

## Fix fulfillment shipped mailer template using wrong header

Fulfillment shipped mailer template was using the cancellation header.

### Pull Requests

- [419](https://github.com/workarea-commerce/workarea/pull/419)

## Change HashUpdate to use the setter instead of mutation

Simply mutating the value doesn't work when the field is localized. Mongoid's localization behavior only kicks in when you use the setter.

### Pull Requests

- [417](https://github.com/workarea-commerce/workarea/pull/417)

## Allow setting locale fallbacks for a test

This is useful if you want to test fallback behavior. Tests in base should be agnostic to whether fallbacks are available or not.

### Pull Requests

- [417](https://github.com/workarea-commerce/workarea/pull/417)

## Fix locale fallback getting unexpectedly autoloaded

This can happen in the middle of a test suite, causing apparently random test failure. This freedom patch prevents fallbacks from autoloading. We want to let the implementation make that decision.

### Pull Requests

- [417](https://github.com/workarea-commerce/workarea/pull/417)
