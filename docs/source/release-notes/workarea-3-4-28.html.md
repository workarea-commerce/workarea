---
title: Workarea 3.4.28
excerpt: Patch release notes for Workarea 3.4.28.
---

# Workarea 3.4.28

Patch release notes for Workarea 3.4.28.

## Display Price Range in Admin Pricing SKUs Index Table

The price display in the Pricing SKUs index is somewhat confusing, and
would show different "Regular Price" data depending on the sale state of
the SKU. To resolve this, replace the two price columns with "Sell
Price", a column that renders a price range if there are multiple prices
set on the SKU, and indicates that it's always going to show the price
that a SKU is being sold for. Otherwise, it will just show the `#sell`
price of the SKU.

### Pull Requests

- [369](https://github.com/workarea-commerce/workarea/pull/369)

## Divide By Units Sold in Average Price Calculation

When calculating the average price for a product in its insights,
Workarea was previously using the amount of orders the product appears
in as a divisor. This will not show the correct average price of a
product unless every order only has a quantity of 1, since it includes
the total price of the item rather than its unit price. To make this
number accurately reflect the average price paid per unit on a product,
Workarea now uses the number of units sold as the divisor when
calculating the average unit price of a product.

### Pull Requests

- [375](https://github.com/workarea-commerce/workarea/pull/375)

## Add Trending Searches To Seed Data

Seeds were only generating insights for a single previous week
and month which caused some insights that rely on historical data
to not be generated i.e. trending products and searches.

### Pull Requests

- [381](https://github.com/workarea-commerce/workarea/pull/381)

## Remove Changes Count in Releases Tabular Index

The `#changesets_for_releasable` query cannot be optimized any further
without using some kind of aggregation, and is causing problems for
large amounts of releases on the index page. Remove it from the index so it
won't cause performance problems.

### Pull Requests

- [368](https://github.com/workarea-commerce/workarea/pull/368)


## Randomize Addresses in Seed Data

Workarea now provides random values for street address, city, and state.
All addresses are still in the US, however, so they will still validate
with default configuration. This provides more diverse seed data that
better reflects the real-life admin.

<img width="1324" alt="Screen Shot 2020-02-25 at 3 38 27 PM" src="https://user-images.githubusercontent.com/113026/75285751-349c3080-57e5-11ea-97d4-38379c27f77c.png">

### Pull Requests

- [376](https://github.com/workarea-commerce/workarea/pull/376)

