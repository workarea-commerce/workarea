---
title: Workarea 3.4.35
excerpt: Patch release notes for Workarea 3.4.35.
---

# Workarea 3.4.35

Patch release notes for Workarea 3.4.35

## Reset Geocoder between tests

This ensures individual tests monkeying around with Geocoder config will
get restored before the next test runs.

### Pull Requests

- [458](https://github.com/workarea-commerce/workarea/pull/458)

## Fix promo code counts in admin

Previously, promo codes could only be generated once through the admin,
so rendering the count of all promo codes as the count requested to be
generated was working out. However, as CSV imports and API updates became
more widespread, this began to break down as the `#count` field would
have to be updated each time a new set of promo codes were added.
Instead of reading from this pre-defined field on the code list, render
the actual count of promo codes from the database on the code list and
promo codes admin pages.

### Pull Requests

- [452](https://github.com/workarea-commerce/workarea/pull/452)

## Use display name For applied facet values

When rendering the applied filters, wrap the given facet value in
the `facet_value_display_name` helper, ensuring that the value rendered
is always human readable. This addresses an issue where if the applied
filter value is that of a BSON ID, referencing a model somewhere, the
BSON ID was rendered in place of the model's name.

### Pull Requests

- [451](https://github.com/workarea-commerce/workarea/pull/451)
