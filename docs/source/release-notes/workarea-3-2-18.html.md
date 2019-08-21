---
title: Workarea 3.2.18
excerpt: Patch release notes for Workarea 3.2.18.
---

# Workarea 3.2.18

Patch release notes for Workarea 3.2.18.

## Fix Dragonfly Config Forced To File System

After a bad merge related to the scheduled jobs cleaning patch released
in **v3.1.26**, **v3.2.15**, and **v3.3.7**, the automatic Dragonfly
configuration was accidentally removed, and resulted in uploaded content
being stored to the filesystem. Restore the original code for configuring
Dragonfly automatically to resolve this issue.

**All users of the following Workarea versions should update to this patch
version immediately, especially before deploying to a production/staging
environment:**

- v3.1.26
- v3.1.27
- v3.1.28
- v3.2.15
- v3.2.16
- v3.2.17
- v3.3.7
- v3.3.8
- v3.3.9

### Issues

- [ECOMMERCE-6370](https://jira.tools.weblinc.com/browse/ECOMMERCE-6370)

### Pull Requests

- [3604](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3604/overview)

### Commits

- [f68e75f22377ffbd131b9e7de8d4290bb02f4a59](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/f68e75f22377ffbd131b9e7de8d4290bb02f4a59)
- [ad6b52fb70464c668e80ef00d1d3ef445ffd43f4](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ad6b52fb70464c668e80ef00d1d3ef445ffd43f4)

