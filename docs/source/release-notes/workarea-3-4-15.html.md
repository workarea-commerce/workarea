---
title: Workarea 3.4.15
excerpt: Patch release notes for Workarea 3.4.15.
---

# Workarea 3.4.15

Patch release notes for Workarea 3.4.15.

## Publish Releases In Background Job

When a release is published, but has too many changes, it can cause a
request timeout because it can't be fully published within the allotted
15 seconds in production. To prevent this, Workarea now runs all release
publishing in a background job. The success flash message for when a
release is published has been updated to inform users that changes may
take a little while to apply.

### Issues

- [1](https://github.com/workarea-commerce/workarea/issues/1)

### Pull Requests

- [1](https://github.com/workarea-commerce/workarea/pull/1)

## Fix Incorrect Currency in Mongoid Money Types

Workarea's default values for the Money fields in `Pricing::Override`
didn't previously change currency when `Money.default_currency` is
re-configured in process (like in the case of a multi-site application
with multiple currencies). Ensure that the correct currency is used by
using an Integer type as the default, which will get converted into a
Money type at runtime.

### Issues

- [ECOMMERCE-7067](https://jira.tools.weblinc.com/browse/ECOMMERCE-7067)

### Pull Requests

- [7](https://github.com/workarea-commerce/workarea/pull/7)
- [9](https://github.com/workarea-commerce/workarea/pull/9)

## Remove Minitest Plugin

This existed for CI purposes on Bamboo, and we don't need it here after
moving to Github. It has been moved the `workarea-ci` gem for backwards
compatibility.

### Issues

- [12](https://github.com/workarea-commerce/workarea/issues/12)

### Pull Requests

- [12](https://github.com/workarea-commerce/workarea/pull/12)

## Multi-site config swappable lists

The `Workarea::SwappableList` class does not get duplicated correctly
when `Workarea.config.deep_dup` is used. This was observed while using
multi-site and attempting to change a swappable list for only one site.
Define the `#deep_dup` method to return a new object instead of referencing
the existing one.

### Issues

- [ECOMMERCE-7038](https://jira.tools.weblinc.com/browse/ECOMMERCE-7038)

### Pull Requests

- [13](https://github.com/workarea-commerce/workarea/pull/13)

## Update Default Admin Password

Change the default admin password when an app is seeded. #branding

### Issues

- [10](https://github.com/workarea-commerce/workarea/issues/10)

### Pull Requests

- [10](https://github.com/workarea-commerce/workarea/pull/10)


## Fix Product Images URL from Seeds

Fixes the URL used to download product images in seed data.

### Issues

- [3](https://github.com/workarea-commerce/workarea/issues/3)

### Pull Requests

- [3](https://github.com/workarea-commerce/workarea/pull/3)


