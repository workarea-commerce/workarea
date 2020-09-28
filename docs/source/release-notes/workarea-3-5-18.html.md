---
title: Workarea 3.5.18
excerpt: Patch release notes for Workarea 3.5.18.
---

# Workarea 3.5.18

Patch release notes for Workarea 3.5.18.

## Add append point for admin top of page

Used for the site builder plugin.

### Pull Requests

- [489](https://github.com/workarea-commerce/workarea/pull/489)

## Move rake task logic into modules

This will allow decorating this logic for plugins or builds that need
to. For example, site builder needs to search-index resources that are
unique per-site.

### Pull Requests

- [489](https://github.com/workarea-commerce/workarea/pull/489)

## Fix constant loading error related to metrics

Sometimes an error will be raised when Workarea middleware is doing
segmentation logic around `Metrics::User`.

### Pull Requests

- [489](https://github.com/workarea-commerce/workarea/pull/489)

## Add minor remote selects features to support site builder

This includes an option for the dropdown parent, and an option to allow
autosubmitting a remote select upon selection.

### Pull Requests

- [489](https://github.com/workarea-commerce/workarea/pull/489)

## Add param to allow disabling the admin toolbar in the storefront

Used in the site builder plugin. Add disable_admin_toolbar=true to the
query string to turn off the admin toolbar for that page.

### Pull Requests

- [489](https://github.com/workarea-commerce/workarea/pull/489)

## Add Rack env key for checking whether it's an asset request

This is useful for plugins like site builder. This also reduces
allocations by moving the regex into a constant and consolidates the
check from multiple spots.

This also skips force passing Rack::Cache for asset requests if you're
an admin (minor performance improvement).

### Pull Requests

- [489](https://github.com/workarea-commerce/workarea/pull/489)

## Add append point for storefront admin toolbar

Used for the site builder plugin.

### Pull Requests

- [489](https://github.com/workarea-commerce/workarea/pull/489)

## Pass user into append point

This is to be consistent in how appended partials use data.

### Pull Requests

- [489](https://github.com/workarea-commerce/workarea/pull/489)

## Add asset index view heading append point

Used for the site builder plugin.

### Pull Requests

- [489](https://github.com/workarea-commerce/workarea/pull/489)

## Add modifier for better disabled workflow button display

This makes it visually clearer that a workflow button is disabled.

### Pull Requests

- [489](https://github.com/workarea-commerce/workarea/pull/489)

## Visually improve changesets card when no changesets

This was unstyled before this change.

### Pull Requests

- [489](https://github.com/workarea-commerce/workarea/pull/489)

## Add permissions To Admin::ConfigurationsController

Admins without "Settings" access are no longer able to access the
administrable configuration settings defined in a Workarea application's
initializer.

### Pull Requests

- [494](https://github.com/workarea-commerce/workarea/pull/494)

## Fix admin configuration for email addresses

The hard-coded `config.email_from` and `config.email_to` settings
conflict with the out-of-box administrable configuration for the "Email
From" and "Email To" settings. This causes a warning for admins that
explain why the settings on "Email To" and "Email From" won't take
effect. Since the whole purpose of moving these settings to admin
configuration was to let admins actually change them, the
`config.email_from` and `config.email_to` settings have been removed
from both default configuration and the `workarea:install` generator.

### Pull Requests

- [493](https://github.com/workarea-commerce/workarea/pull/493)

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
