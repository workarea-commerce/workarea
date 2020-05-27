---
title: Workarea 3.4.33
excerpt: Patch release notes for Workarea 3.4.33.
---

# Workarea 3.4.33

Patch release notes for Workarea 3.4.33

## Correct/clarify Dragonfly configuration warning

This warning's language was based on outdated functionality, this updates it
to reflect what happens currently.

### Commits

- [16589e9](https://github.com/workarea-commerce/workarea/commit/16589e964f6ac48753172a98288aea4223a525b6)

## Remove caching from direct upload CORS requests

The caching continues to give us problems, and this isn't a high-traffic
part of the system so there isn't a practical need for it.

### Pull Requests

- [430](https://github.com/workarea-commerce/workarea/pull/430)

## Fix incorrect import errors

When an import fails due to a missing `DataFile::Import` document, the
`ProcessImport` worker will raise a nil error due to the ensure. This
fixes by ensuring the `DocumentNotFound` error gets raised.

### Pull Requests

- [432](https://github.com/workarea-commerce/workarea/pull/432)
