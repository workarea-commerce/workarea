---
title: Workarea 3.4.36
excerpt: Patch release notes for Workarea 3.4.36.
---

# Workarea 3.4.36

Patch release notes for Workarea 3.4.36

## Bump rack version

Fixes CVE-2020-8184

### Pull Requests

- [460](https://github.com/workarea-commerce/workarea/pull/460)

## Add permissions append point to user workflow

This allows a plugin (such as API) to specify permissions categories when
admins are either editing or creating a user.

### Pull Requests

- [457](https://github.com/workarea-commerce/workarea/pull/457)

## Patch Jbuilder to support varying cache

Previously, admins were not able to see up-to-date data in API requests
due to the `#cache!` method in Jbuilder not being patched to skip
caching when an admin is logged in. To resolve this, Workarea now
applies the same patch to Jbuilder as it does to ActionView. Reading
from the cache is now skipped if you're logged in as an admin, and cache
keys are appended with the configured `Cache::Varies` just the same as
in regular Haml views.

### Pull Requests

- [461](https://github.com/workarea-commerce/workarea/pull/461)
