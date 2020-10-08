---
title: Workarea 3.5.20
excerpt: Patch release notes for Workarea 3.5.20.
---

# Workarea 3.5.20

Patch release notes for Workarea 3.5.20.

## Redirect back to the previous page after stopping impersonation

Previously we redirected to the user's show page, which can be pretty
disorienting.

### Pull Requests

- [514](https://github.com/workarea-commerce/workarea/pull/514)

## Fix safe navigation method calls in navigation menu partial

This would raise if the menu content is nil.

### Pull Requests

- [528](https://github.com/workarea-commerce/workarea/pull/528)

## Improve clarity of discount verbiage

This hopes to address some recent confusion around how the discount
works.

### Pull Requests

- [518](https://github.com/workarea-commerce/workarea/pull/518)

## Rename Admin::ProductViewModel#options to avoid conflict with normal options method

### Pull Requests

- [530](https://github.com/workarea-commerce/workarea/pull/530)

## Fix precision of tax rates UI

The `:step` values of the new/edit forms and precision configuration for
`#number_to_percentage` were not only rounding certain tax rates to an
incorrect number, but were also showing a bunch of insignificant zeroes
in the admin for tax rates. To resolve this, configure
`#number_to_percentage` to have 3-decimal precision, and strip all
insignificant zeroes from the display, leaving the admin with a much
nicer percentage display than what was presented before.

### Pull Requests

- [517](https://github.com/workarea-commerce/workarea/pull/517)

## Fix undecoratable test setup in an integration test

This hopes to address some recent confusion around how the discount
works.

### Pull Requests

- [519](https://github.com/workarea-commerce/workarea/pull/519)

## Update preconfigured session length to match recommendations

The app's configuration will override this change.

### Pull Requests

- [527](https://github.com/workarea-commerce/workarea/pull/527)

## Remove unnecessary Capybara blocking when testing content is not present

Capybara's `page.has_content?` and similar methods block until a timeout
is reached if they can't find the content. This is not what we want if
we're checking that the content does *not* exist, switch to using
`refute_text` in these scenarios.

The timeout is equal to the number of installed plugins and we have
client apps with 30+, which means that the 38 instances removed in this
commit could represent twenty minutes of unnecessary blocking in some
scenarios.

### Pull Requests

- [525](https://github.com/workarea-commerce/workarea/pull/525)
- [526](https://github.com/workarea-commerce/workarea/pull/526)

## Improve UX of default search filter sizes

Hopefully this will help clarify the relationships in the filter size
configurations.

### Pull Requests

- [524](https://github.com/workarea-commerce/workarea/pull/524)
