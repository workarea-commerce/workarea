---
title: Workarea 3.0.25
excerpt: Fixes a cross-site scripting vulnerability by properly escaping HTML within the “Recent Searches” card of the Admin “Search” dashboard.
---

# Workarea 3.0.25

## Fixes XSS Vulnerability in Admin Search Dashboard

Fixes a [cross-site scripting](https://www.owasp.org/index.php/Cross-site_Scripting_(XSS)) vulnerability by properly escaping HTML within the “Recent Searches” card of the Admin “Search” dashboard.

**This patch fixes a security vulnerability!** The fix is applied in a JavaScript file, which your application is potentially overriding. If this is true for your application, **you must apply the patch manually within your copy of the affected file**. Review the changes below to ensure your application is patched properly.

### Issues

- [ECOMMERCE-5638](https://jira.tools.weblinc.com/browse/ECOMMERCE-5638)

### Pull Requests

- [3070](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3070/overview)

### Commits

- [28653ab34dec49e9452276bd43e4ed5e20724e9a](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/28653ab34dec49e9452276bd43e4ed5e20724e9a)
- [284c79526b6785112436e7fbaaace12ffba5d7b7](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/284c79526b6785112436e7fbaaace12ffba5d7b7)

