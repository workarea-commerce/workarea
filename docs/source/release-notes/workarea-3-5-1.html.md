---
title: Workarea 3.5.1
excerpt: Patch release notes for Workarea 3.5.1.
---

# Workarea 3.5.1

Patch release notes for Workarea 3.5.1.

## Ignore `updated_at` When Importing

Ignore the `updated_at` field when importing from JSON or a CSV so
Mongoid can update these timestamps and bust the proper caches when
necessary.

### Pull Requests

- [275](https://github.com/workarea-commerce/workarea/pull/275)

## Fix Error When Generating New Application

Workarea now requires the correct files needed for generators to run
properly.

### Pull Requests

- [274](https://github.com/workarea-commerce/workarea/pull/274)

## Remove Randomly Failing Content / Segments Test

This test caused intermittent failures in Workarea's mega-build, and
thus the decision was made to remove this test until it can be rewritten
in a more predictable way.

### Pull Requests

- [260](https://github.com/workarea-commerce/workarea/pull/260)
- [265](https://github.com/workarea-commerce/workarea/pull/265)

## Improve Redis Configuration Defaults

Workarea's Redis configuration got an improvement in robustness,
allowing partial configuration values that will always end up falling
back to defaults.

### Pull Requests

- [282](https://github.com/workarea-commerce/workarea/pull/282)

## Fix Error When Adding a Content Page to Taxonomy For a Segment Release

Remove the `Releasable` module from `Content::BlockDraft` since this is
not actually releasable and the extra callback code is what was causing
the error.

### Pull Requests

- [261](https://github.com/workarea-commerce/workarea/pull/261)


## Fix Metrics/Reports/Insights Test Failures When Time Zone Changes

Changing `config.time_zone` in your configuration caused
metrics/reports/insights tests to fail,because the dates being compared
are no longer in UTC and Mongoid fails to convert them as such in an
aggregation query. Update these dates to always be in UTC so the queries
won't cause test failures when you change your Rails time zone.

### Issues

- [278](https://github.com/workarea-commerce/workarea/issues/278)

### Pull Requests

- [279](https://github.com/workarea-commerce/workarea/pull/279)

