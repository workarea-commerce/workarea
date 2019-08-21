---
title: Workarea 3.3.28
excerpt: Patch release notes for Workarea 3.3.28.
---

# Workarea 3.3.28

Patch release notes for Workarea 3.3.28.

## Fix Exact Match Functionality Being Triggered By a Partial Name Match

Depending on how boosts and name phrase match storing are configured,
multiple "exact matches" can be found from a single partial match in
Elasticsearch. To prevent this, Workarea will only `return` the single
match if it is indeed a singleton, not if there are multiple exact
matches found.

### Issues

- [ECOMMERCE-6934](https://jira.tools.weblinc.com/browse/ECOMMERCE-6934)

### Pull Requests

- [4062](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4062/overview)

## Backport Update to Payment Factory

After builds noticed inexplicable failing tests in v3.2.x when
installing **workarea-reviews**, it was discovered that the updates to
the `#capture_order` factory method didn't get backported to earlier
versions. This change allows workarea-reviews tests to pass against
v3.2.x, since it makes use of that method.

### Issues

- [ECOMMERCE-6935](https://jira.tools.weblinc.com/browse/ECOMMERCE-6935)

### Pull Requests

- [4074](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4074/overview)

## Fix Chrome WebDriver Connection Issues in System Tests

After the update to Chrome 75, many builds experienced issues with
the `chromedriver` in system tests becoming disconnected from the actual
Chrome installation. It was eventually discovered that Chrome 75 enables
"W3C mode" by default, which is an implementation of the [W3C WebDriver
1.0 Specification](https://www.w3.org/TR/webdriver1/). Unfortunately,
this update broke a lot of stuff, specifically with regards to the
console/logging APIs, which are not yet included in the spec. To resolve
this, Workarea has turned off W3C mode until it becomes a bit more stable.

This also adds configuration via ENV variables for which options and
args to pass to Chrome when running tests: `$WORKAREA_HEADLESS_CHROME_ARGS` and
`$WORKAREA_HEADLESS_CHROME_OPTIONS`.

`Workarea.config.headless_chrome_options` turns out to be poorly named
because the Selenium driver accepts both args and options, and both
may need to be configured to fix problems in Chrome. In a future minor
release, Workarea will allow both args and options to be defined in
`Workarea.config`.

### Issues

- [ECOMMERCE-6940](https://jira.tools.weblinc.com/browse/ECOMMERCE-6940)

### Pull Requests

- [4072](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4072/overview)

## Improve Consistency of Order Pricing Display

When viewing an order summary in the storefront, the price of each item
matches its original price, with no discounts applied. This is somewhat
confusing as the totals don't add up to the subtotal of the order. The
order summary page now renders the `item.total_price` so that these
totals match up in the end.

Additionally, the wording surrounding item pricing has been altered to
coincide with the change in the price. Since items no longer reflect the
original unit price, but rather the total price, the wording has been
changed to "Qty 2: $20.00", rather than "2 @ $10.00 each".

### Issues

- [ECOMMERCE-6809](https://jira.tools.weblinc.com/browse/ECOMMERCE-6809)

### Pull Requests

- [4061](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4061/overview)

## Prevent Double Application of Order-Level Discounts When Determining Packages

In the `Workarea::Packaging` class, the subtotal of all shippable items
already includes the order-level discounts after pricing is performed,
since `Order::Item#total_value` is not the total prior to discounts,
only tax and shipping. However, order-level discounts were being
summed and deducted from the `Packaging#total_value`, resulting in a
miscalculation of the total price of the Order. This problem doesn't
manifest itself until there are a sufficient number of shipping tiers
(at the very least, 3), because either the top or bottom tier will be
used anyway. Remove the code for subtracting order-level discounts from
the total value of the package, so that the proper shipping price will
be displayed to the user in checkout.

### Issues

- [ECOMMERCE-6918](https://jira.tools.weblinc.com/browse/ECOMMERCE-6918)

### Pull Requests

- [4051](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4051/overview)

## Fix New Release Form Creating Duplicates

The "with a new release" selection on the release selector pops up a
mini form which prompts the user for the name of their new release. This
form is dismissed if the user clicks the button, but still allows
potential user input (including multiple submits), causing duplicate
releases to be accidentally created if one hits enter _and_ clicks the
"Add" button before the page refreshes. Prevent this by adding
`data-disable-with` to the button so that it can't be submitted twice in
the same request cycle.

### Issues

- [ECOMMERCE-6837](https://jira.tools.weblinc.com/browse/ECOMMERCE-6837)

### Pull Requests

- [4052](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4052/overview)

## Fix Duplication in Search Suggestions Indexing

This is caused by not using the query ID as the ID for the suggestion in
its index after the new metrics engine in v3.4. Additionally, the
`BulkIndexSearches` job was no longer in the scheduler, it has been
re-added.

### Issues

- [ECOMMERCE-6927](https://jira.tools.weblinc.com/browse/ECOMMERCE-6927)

### Pull Requests

- [4049](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4049/overview)

