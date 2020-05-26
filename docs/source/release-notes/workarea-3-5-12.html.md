---
title: Workarea 3.5.12
excerpt: Patch release notes for Workarea 3.5.12.
---

# Workarea 3.5.12

Patch release notes for Workarea 3.5.12.

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

## Don't set a blank tracking email in checkout

Doing this has the potential to create an incorrect tracking email,
which could cause a visitor's segments to change in checkout.

### Pull Requests

- [429](https://github.com/workarea-commerce/workarea/pull/429)

## Add paranoid fallback for segment metrics lookup

Although this should never happen, giving a user incorrect segments
could have important consequences. If the email cookie is removed or
missing for some other reason, it doesn't hurt to fallback to looking up
based on the user model (even though this is an additional query) when
we know they're logged in.

### Pull Requests

- [429](https://github.com/workarea-commerce/workarea/pull/429)
