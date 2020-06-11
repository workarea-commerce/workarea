---
title: Workarea 3.5.13
excerpt: Patch release notes for Workarea 3.5.13.
---

# Workarea 3.5.13

Patch release notes for Workarea 3.5.13.

## Fix query caching in Releasable

When reloading a model to get an instance for a release, if the model
had already been loaded, a cached version of the model was returned.
This causes incorrect values on the instance you thought you were getting
for a release.

This first manifested as a bug where adding a featured product that
had a release change to make it active caused reindexing to make it
active but it shouldn't have been.

### Pull Requests

- [434](https://github.com/workarea-commerce/workarea/pull/434)

## Fix storefront indexing when releases are rescheduled

When releases get rescheduled, the storefront index can end up with
duplicate and/or incorrect entries. This adds a worker which updates the
index with minimal querying/updating.

### Pull Requests

- [442](https://github.com/workarea-commerce/workarea/pull/442)

## Add index for releasable fields on changesets, correct order fraud index

These indexes improve performance.

### Pull Requests

- [438](https://github.com/workarea-commerce/workarea/pull/438)

## Fix releases shifting day on the calendar when scrolling

This was caused by legacy timezone code that's irrelevant since we
shifted to a fix server-side timezone for the admin.

### Pull Requests

- [444](https://github.com/workarea-commerce/workarea/pull/444)

## Add additional append points to admin

Adds append points to product details, product content, variant and inventory SKU
to support new plugins.

### Pull Requests

- [441](https://github.com/workarea-commerce/workarea/pull/441)

## Fix reindexing of featured product resorting within a release

Resorting featured products within a release causes an inaccurate set of
changes from Mongoid's perspective, since it is only looking at what's
live vs what's going to be released. The changes within the release
aren't represented. This can manifest as incorrect sorts when previewing
in the storefront.

### Pull Requests

- [446](https://github.com/workarea-commerce/workarea/pull/446)

## Fix duplicate products in release previews for featured product changes

When featured product changes stack in a release, duplicates will show
when previewing. This is due to the product's Elasticsearch documents
missing changeset IDs for releases scheduled after the release that
document is for. This fixes by indexing those release IDs as well.

Note that this will require a reindex to see the fix immediately. But
there's no harm in letting it roll out as products gradually get
reindexed.

### Pull Requests

- [446](https://github.com/workarea-commerce/workarea/pull/446)

## Fix incorrect shipping options error flash message

A flash error incorrectly showed when the order doesn't require shipping,
and addresses are updated.

### Pull Requests

- [433](https://github.com/workarea-commerce/workarea/pull/433)

## Bump Kaminari dependency to fix security alert

### Pull Requests

- [435](https://github.com/workarea-commerce/workarea/pull/435)

## Bump rack-attack to latest version

This fixes rack-attack keys without TTLs set piling up in Redis. This has caused hosting problems.

### Pull Requests

- [437](https://github.com/workarea-commerce/workarea/pull/437)

## Don't assume promo codes for indexing discounts

A custom discount may be implemented that doesn't use promo codes.

### Pull Requests

- [440](https://github.com/workarea-commerce/workarea/pull/440)

## Handle error from attempting to fetch missing S3 CORS configuration

If a bucket has no CORS configurations, the app errored because it was trying to
merge the new one. This fixes that to gracefully create a new configuration.

### Pull Requests

- [439](https://github.com/workarea-commerce/workarea/pull/439)

## Add QueuePauser to pause Sidekiq queues, pause for search reindexing

This fixes a situation where Elasticsearch mappings aren't created because Sidekiq
jobs are processing indexing jobs while the indexes are being reset.

### Pull Requests

- [443](https://github.com/workarea-commerce/workarea/pull/443)

## Bump Geocoder

This fixes an irrelevant bundler-audit CVE warning, and adds/updates a bunch of
Geocoder lookup options.

See https://github.com/alexreisner/geocoder/blob/master/CHANGELOG.md for more info.

### Pull Requests

- [445](https://github.com/workarea-commerce/workarea/pull/445)
