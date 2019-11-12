---
title: Workarea 3.0.66
excerpt: Patch release notes for Workarea 3.0.66.
---

# Workarea 3.0.66

Patch release notes for Workarea 3.0.66.

## Update Haml and Loofah For Security Fixes

Several security updates occurred in the Haml and Loofah gems, and Workarea's
dependencies have been updated to account for the latest patch versions.

### Commits

- [ba523a2d013997f9a06e96bc9ec4f294ba6b3b9e](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ba523a2d013997f9a06e96bc9ec4f294ba6b3b9e)
- [a9f2cb309dee0950b1ee61256ca7063d4e68c997](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/a9f2cb309dee0950b1ee61256ca7063d4e68c997)

## Fix Logout From Pages Without Authenticity Tokens

Rails checks for an `authenticity_token` parameter (or header) on each non-GET
request. HTTP-cached pages may not include this token, so clicking the "Log
Out" link at the top of the site won't actually log you out. This disables the
`verify_authenticity_token` check so logouts work as expected.

### Pull Requests

- [4179](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4179/overview)

## Add Append Point to Order Confirmation Page

Adds the `storefront.checkout_confirmation_text` append point immediately
underneath where checkout content is rendered.

### Pull Requests

- [4178](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4178/overview)
