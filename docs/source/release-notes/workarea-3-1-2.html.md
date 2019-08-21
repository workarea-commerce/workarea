---
title: Workarea 3.1.2
excerpt: Moves enforce host logic from Workarea::ApplicationController to a new middleware, Workarea::EnforceHostMiddleware, to avoid depending on Rails routing. Adds new config skip_enforce_host to allow skipping enforcing host.
---

# Workarea 3.1.2

## Fixes Enforce Host for Paths that Don't Match Routes

Moves enforce host logic from `Workarea::ApplicationController` to a new middleware, `Workarea::EnforceHostMiddleware`, to avoid depending on Rails routing. Adds new config _skip\_enforce\_host_ to allow skipping enforcing host.

### Issues

- [ECOMMERCE-5246](https://jira.tools.weblinc.com/browse/ECOMMERCE-5246)

### Pull Requests

- [2802](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2802/overview)

### Commits

- [e36e7072d449d421a0b543e69f4eb1e1929d2310](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/e36e7072d449d421a0b543e69f4eb1e1929d2310)
- [0f6bbc62202a3dc7590a2e841a8d00a0c597879f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/0f6bbc62202a3dc7590a2e841a8d00a0c597879f)
- [4f04baf1b2677f7eddb685406fd7de3bc36090b2](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/4f04baf1b2677f7eddb685406fd7de3bc36090b2)

## Returns Soft 404 for Searches with No Results

Changes the HTTP status code for searches with no results from 200 OK to 404 Not Found, as [recommended by Google](https://support.google.com/webmasters/answer/181708).

### Issues

- [ECOMMERCE-4889](https://jira.tools.weblinc.com/browse/ECOMMERCE-4889)

### Commits

- [47bd6622d5405ff116503345ff5f9a647d5dbfd5](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/47bd6622d5405ff116503345ff5f9a647d5dbfd5)
- [b3c5e43d504b87c30c28a6024fb0bd717cd1ba8a](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b3c5e43d504b87c30c28a6024fb0bd717cd1ba8a)

## Enables Explicit ID on Toggle Buttons to Enforce Unique DOM IDs

Adds `id` option to `Workarea::Admin::ApplicationHelper#toggle_button_for` to allow enforcing unique IDs on Admin toggle buttons. Fixes a few instances of duplicate DOM IDs in the Admin.

### Issues

- [ECOMMERCE-5248](https://jira.tools.weblinc.com/browse/ECOMMERCE-5248)

### Pull Requests

- [2804](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2804/overview)

### Commits

- [d09e350b34bda2c2c2cd3929d2341bbec1f515cf](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/d09e350b34bda2c2c2cd3929d2341bbec1f515cf)
- [03913fda6fbeba3ddd8e28394da632f80cd5ac57](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/03913fda6fbeba3ddd8e28394da632f80cd5ac57)

