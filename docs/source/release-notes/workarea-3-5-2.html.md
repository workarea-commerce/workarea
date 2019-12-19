---
title: Workarea 3.5.2
excerpt: Patch release notes for Workarea 3.5.2.
---

# Workarea 3.5.2

Patch release notes for Workarea 3.5.2.

## Use the Rack session ID cookie value for metrics session IDs

Rack >= 2.0.8 adds the idea private/public session IDs to prevent timing
attacks where a session ID can be stolen. This is big for sessions stored
in databases because the session can then be stolen.

Workarea only supports a cookie session store, so we can continue to
safely use the cookie value of the session ID for metrics lookups.

You can learn more about the Rack vulnerability here:
https://github.com/rack/rack/security/advisories/GHSA-hrqr-hxpp-chr3

### Pull Requests

- [294](https://github.com/workarea-commerce/workarea/pull/294)

## Fix bad method call in migrate task

`each_by` needs to be called on a scope.

### Pull Requests

- [294](https://github.com/workarea-commerce/workarea/pull/294)

## Don't bother with segmentation for SVG requests

We found this this was happening due to failures in system tests with this bug.

### Pull Requests

- [294](https://github.com/workarea-commerce/workarea/pull/294)

## Add a shortcut for editing the footer to the admin

Tiny feature addition before most v3.5 upgrades get underway.

### Pull Requests

- [293](https://github.com/workarea-commerce/workarea/pull/293)
