---
title: Workarea 3.2.44
excerpt: Patch release notes for Workarea 3.2.44.
---

# Workarea 3.2.44

Patch release notes for Workarea 3.2.44.

## Use the Rack session ID cookie value for user activity IDs

Rack >= 2.0.8 adds the idea private/public session IDs to prevent timing
attacks where a session ID can be stolen. This is big for sessions stored
in databases because the session can then be stolen.

Workarea only supports a cookie session store, so we can continue to
safely use the cookie value of the session ID for metrics lookups.

You can learn more about the Rack vulnerability here:
https://github.com/rack/rack/security/advisories/GHSA-hrqr-hxpp-chr3

### Pull Requests

- [4184](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4184/overview)

## Update tests referencing 2020

The credit card expiration year 2020 was hard-coded into many Workarea
integration tests, and would fail when January 2020 passes. Update these
tests to always set the credit card expiration year to 3 years in
advance of when the test runs so this won't happen again in the future.

### Pull Requests

- [4183](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4183/overview)

## Fix tax rates import test for compatibility with newer versions of Mongo

This was requested by the hosting team.

### Pull Requests

- [4185](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4185/overview)
