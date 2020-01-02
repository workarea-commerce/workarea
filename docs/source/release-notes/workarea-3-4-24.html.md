---
title: Workarea 3.4.24
excerpt: Patch release notes for Workarea 3.4.24.
---

# Workarea 3.4.24

Patch release notes for Workarea 3.4.24.

## Use the Rack session ID cookie value for metrics session IDs

Rack >= 2.0.8 adds the idea private/public session IDs to prevent timing
attacks where a session ID can be stolen. This is big for sessions stored
in databases because the session can then be stolen.

Workarea only supports a cookie session store, so we can continue to
safely use the cookie value of the session ID for metrics lookups.

You can learn more about the Rack vulnerability here:
https://github.com/rack/rack/security/advisories/GHSA-hrqr-hxpp-chr3

### Pull Requests

- [296](https://github.com/workarea-commerce/workarea/pull/296)
