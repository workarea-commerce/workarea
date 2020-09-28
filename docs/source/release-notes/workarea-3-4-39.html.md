---
title: Workarea 3.4.39
excerpt: Patch release notes for Workarea 3.4.39.
---

# Workarea 3.4.39

Patch release notes for Workarea 3.4.39

## Fix wrong sorting on default admin index pages

The query for an admin index page can end up inadvertantly introduce a
scoring variation, which can cause results to not match the `updated_at`
default sort.

This makes `updated_at` the true default sort, and allows the general
admin search to override, where `_score` is still the desired default
sort.

### Pull Requests

- [487](https://github.com/workarea-commerce/workarea/pull/487)

## Handle missing or invalid current impersonation

This surfaced as a random failing test, this should make the feature more robust.

### Pull Requests

- [490](https://github.com/workarea-commerce/workarea/pull/490)

## Set default inventory policy to "Standard" in Create Product workflow

When creating a new product through the workflow, setting the
"Inventory" on a particular SKU would still cause the `Inventory::Sku`
to be created with the "Ignore" policy rather than "Standard". Setting
inventory on a SKU now automatically causes the `Inventory::Sku` record
to be created with a policy of "Standard" so as to deduct the given
inventory to the varaint. When no inventory is given, Workarea will fall
back to the default of "Ignore".

### Pull Requests

- [495](https://github.com/workarea-commerce/workarea/pull/495)
