---
title: Workarea 3.0.16
excerpt: Moves enforce host logic from Workarea::ApplicationController to a new middleware, Workarea::EnforceHostMiddleware, to avoid depending on Rails routing. Adds new config skip_enforce_host to allow skipping enforcing host.
---

# Workarea 3.0.16

## Fixes Enforce Host for Paths that Don't Match Routes

Moves enforce host logic from `Workarea::ApplicationController` to a new middleware, `Workarea::EnforceHostMiddleware`, to avoid depending on Rails routing. Adds new config _skip\_enforce\_host_ to allow skipping enforcing host.

### Issues

- [ECOMMERCE-5246](https://jira.tools.weblinc.com/browse/ECOMMERCE-5246)

### Pull Requests

- [2802](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2802/overview)

### Commits

- [0f6bbc62202a3dc7590a2e841a8d00a0c597879f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/0f6bbc62202a3dc7590a2e841a8d00a0c597879f)
- [4f04baf1b2677f7eddb685406fd7de3bc36090b2](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/4f04baf1b2677f7eddb685406fd7de3bc36090b2)

## Returns Soft 404 for Searches with No Results

Changes the HTTP status code for searches with no results from 200 OK to 404 Not Found, as [recommended by Google](https://support.google.com/webmasters/answer/181708).

### Issues

- [ECOMMERCE-4889](https://jira.tools.weblinc.com/browse/ECOMMERCE-4889)

### Commits

- [47bd6622d5405ff116503345ff5f9a647d5dbfd5](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/47bd6622d5405ff116503345ff5f9a647d5dbfd5)

