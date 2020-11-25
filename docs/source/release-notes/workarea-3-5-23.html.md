---
title: Workarea 3.5.23
excerpt: Patch release notes for Workarea 3.5.23.
---

# Workarea 3.5.23

Patch release notes for Workarea 3.5.23.

## Shorten index name

Mongo will raise when index names exceed a certain length. For example,
having a long Workarea.config.site_name could cause this.

### Pull Requests

- [554](https://github.com/workarea-commerce/workarea/pull/554)

## Fix missing jump to positions breaking jump to

Ruby raises when nil is compared, so default these values.

### Pull Requests

- [551](https://github.com/workarea-commerce/workarea/pull/551)

## Fix missing instance variable in cart items view

The `@cart` instance variable was only being conditionally defined if
`current_order.add_item` succeeded. This caused an error if `#add_item`
happens to fail when calling `POST /cart/items` from the storefront,
resulting in a 500 error. To prevent this error, the definition of this
variable has been moved above the condition.

### Pull Requests

- [555](https://github.com/workarea-commerce/workarea/pull/555)

## Prevent error on missing custom template view model class

Typically, custom product templates use their own subclass of
`Workarea::Storefront::ProductViewModel`, but this isn't supposed to be
necessary if there's no custom logic that needs to be in the view model
layer. However, when developers tried to add a custom template without
the view model, they received an error. To prevent this, Workarea will
now catch the `NameError` thrown by `Storefront::ProductViewModel.wrap`
in the event of a custom product template not having a view model
defined.

### Pull Requests

- [556](https://github.com/workarea-commerce/workarea/pull/556)

## Fix Elasticsearch indexes when changing locales in tests

This ensures the proper search indexes are in place when you switch
locales for an integration test.

### Pull Requests

- [559](https://github.com/workarea-commerce/workarea/pull/559)

## Add warning to inform developers why redirects aren't working locally

This has confused developers a couple of times, so hopefully adding a
warning will help.

### Pull Requests

- [560](https://github.com/workarea-commerce/workarea/pull/560)

## Add warning to inform developers why redirects aren't working locally

This has confused developers a couple of times, so hopefully adding a
warning will help.

### Bump jquery-rails to patch XSS vulnerabilities

- [561](https://github.com/workarea-commerce/workarea/pull/561)
