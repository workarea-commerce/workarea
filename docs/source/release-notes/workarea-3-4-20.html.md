---
title: Workarea 3.4.20
excerpt: Patch release notes for Workarea 3.4.20.
---

# Workarea 3.4.20

Patch release notes for Workarea 3.4.20.

## Fix logout from pages without authenticity tokens

On pages without authenticity tokens (like HTTP cached pages), clicking
log out won't work because Rails is checking for that. This disables
that check for logout to fix.

### Pull Requests

- [199](https://github.com/workarea-commerce/workarea/pull/199)

## Update Loofah to Gain Security Fixes

Loofah was updated due to [a security
vulnerability](https://github.com/flavorjones/loofah/issues/171), so
it's been bumped in the Workarea dependencies to ensure that you won't
be bitten by an XSS bug in sanitized HTML.

### Pull Requests

- [185](https://github.com/workarea-commerce/workarea/pull/185)

## Increase Reliability of Admin Toolbar System Tests

Due to the usage of `<iframe>` in admin toolbar system tests, they would
fail intermittently since Chrome couldn't always click the element in an
Ajax-ed `within_frame` call. Modify the method in Capybara to also
`wait_for_xhr` prior to running any assertions.

### Pull Requests

- [171](https://github.com/workarea-commerce/workarea/pull/171)

## Fix Missing Aspect Ratio Attribute

Instead of trying to calculate the `#inverse_aspect_ratio` in Dragonfly,
use the `#aspect_ratio` field and calculate its inverse when requested.

### Pull Requests

- [170](https://github.com/workarea-commerce/workarea/pull/170)
