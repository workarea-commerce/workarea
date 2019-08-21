---
title: Workarea 3.1.34
excerpt: Patch release notes for Workarea 3.1.34.
---

# Workarea 3.1.34

Patch release notes for Workarea 3.1.34.

## Fix Autoloading For Sidekiq Callback Workers

Because Sidekiq callback workers hold references to autoloaded code,
they too must be autoloaded. This is irrelevant in non-development
environments.

### Issues

- [ECOMMERCE-6470](https://jira.tools.weblinc.com/browse/ECOMMERCE-6470)

### Pull Requests

- [3673](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3673/overview)

### Commits

- [663aa14f8ec5b6dfbde616191300c5be68d29a32](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/663aa14f8ec5b6dfbde616191300c5be68d29a32)

## Use HTTP Proxy When Fetching Image URLs With Dragonfly

Fix timeout issues when imports attempt to pull in images from external
URLs by running all background requests in Dragonfly through the
`$HTTP_PROXY`. This is active on all non-local environments that
Workarea runs under (not development or test).

### Issues

- [ECOMMERCE-6451](https://jira.tools.weblinc.com/browse/ECOMMERCE-6451)

### Pull Requests

- [3681](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3681/overview)

### Commits

- [09e69efb45767b046df628adc40c7e8b6948b024](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/09e69efb45767b046df628adc40c7e8b6948b024)
- [72e3b1d31bb481bad1159ed4de8bc37bf4d39df6](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/72e3b1d31bb481bad1159ed4de8bc37bf4d39df6)

## Add Pricing Details Append Point

Adds a new append point to the `workarea/storefront/products#show`
template, which allows for PDP-specific content rendered underneath the
pricing partial.

### Issues

- [ECOMMERCE-6496](https://jira.tools.weblinc.com/browse/ECOMMERCE-6496)

### Pull Requests

- [3693](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3693/overview)

### Commits

- [be7e639c860abafd9026e5d1e0c43efb92034901](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/be7e639c860abafd9026e5d1e0c43efb92034901)

## Clear Unique Jobs Daily

Sidekiq Unique Jobs (in v5.x) does not clear out the key(s) it stores in
Redis to maintain job uniqueness. This results in out-of-memory (or disk
space) errors on the Redis server cluster. Workarea will now these unique
job keys out every day manually (with a scheduled job) in order to avoid
this problem.

### Issues

- [ECOMMERCE-6481](https://jira.tools.weblinc.com/browse/ECOMMERCE-6481)

### Pull Requests

- [3689](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3689/overview)

### Commits

- [68b9058ef166c8ce0cb37e5b1a9f06e24a671016](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/68b9058ef166c8ce0cb37e5b1a9f06e24a671016)

## Safelist Kubernetes Health Checks In `Rack::Attack`

Kubernetes health checks use the non-standard IP address `127.0.0.1:0`
to access the Workarea app server, causing an error when being
interpreted by the `IPAddr` class in Ruby. Prevent this error by
adding the aforementioned IP address to the safelist prior to any other
rules, the short-circuit prevents the IP from ever being instantiated as
an `IPAddr`.

### Issues

- [ECOMMERCE-6484](https://jira.tools.weblinc.com/browse/ECOMMERCE-6484)

### Pull Requests

- [3691](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3691/overview)

### Commits

- [3038f637d1a55791459acda62c0b70f8eab3108f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/3038f637d1a55791459acda62c0b70f8eab3108f)

## Improve Accuracy Of Placed Orders Query

Explicitly setting `nil` as the `:placed_at` timestamp for a given Order
caused it to be included in the query for all placed orders, because of
how MongoDB interprets the `$exists` query. Since the value was
explicitly set on the document, that document's attribute is considered to be
in existence, however, Workarea applications (by way of Mongoid) do not distinguish
between a `nil`/`null` value and a missing value. Update the
`Workarea::Order.placed` query to reflect this, filtering by whether
`:placed_at` is greater than (`$gt`) the first possible UNIX epoch time
value, `0`.

### Issues

- [ECOMMERCE-6473](https://jira.tools.weblinc.com/browse/ECOMMERCE-6473)

### Pull Requests

- [3687](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3687/overview)

### Commits

- [0ad269c015cf36c09035f72903c75f68c356f640](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/0ad269c015cf36c09035f72903c75f68c356f640)

