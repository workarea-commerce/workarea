---
title: Workarea 3.5.8
excerpt: Patch release notes for Workarea 3.5.8.
---

# Workarea 3.5.8

Patch release notes for Workarea 3.5.8.

## Handle missing price in sell_price method

This fixes errors on pricing SKUs index page in the admin.

### Pull Requests

- [394](https://github.com/workarea-commerce/workarea/pull/394)

## Sort jump to results by last updated_at (within each type)

This adds updated_at as a sort in jump to so most recent results show at
the top within their type. The types are still sorted the same.

### Pull Requests

- [397](https://github.com/workarea-commerce/workarea/pull/397)


## Allow for blank index URLs in import emails

This can happen for models without index pages, like wish lists.

### Pull Requests

- [402](https://github.com/workarea-commerce/workarea/pull/402)

## Add "critical" endpoint for Easymon checks

Only Elasticsearch, MongoDB and Redis are critical services for running
the application.

### Pull Requests

- [398](https://github.com/workarea-commerce/workarea/pull/398)

## Remove unneeded grid modifier

Causes misalignment of the users index aux navigation append point.

### Pull Requests

- [Commit](https://github.com/workarea-commerce/workarea/commit/7a716f7b3b93b2f4ee2174bec2c260b630db7bb6)

## Fix incorrect placeholder text

### Pull Requests

- [403](https://github.com/workarea-commerce/workarea/pull/403)
