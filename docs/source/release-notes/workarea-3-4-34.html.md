---
title: Workarea 3.4.34
excerpt: Patch release notes for Workarea 3.4.34.
---

# Workarea 3.4.34

Patch release notes for Workarea 3.4.34

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
