---
title: Workarea 3.4.23
excerpt: Patch release notes for Workarea 3.4.23.
---

# Workarea 3.4.23

Patch release notes for Workarea 3.4.23.

## Ignore `updated_at` When Importing

Ignore the `updated_at` field when importing from JSON or a CSV so
Mongoid can update these timestamps and bust the proper caches when
necessary.

### Pull Requests

- [275](https://github.com/workarea-commerce/workarea/pull/275)

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

