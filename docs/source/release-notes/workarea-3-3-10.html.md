---
title: Workarea 3.3.10
excerpt: Patch release notes for Workarea 3.3.10.
---

# Workarea 3.3.10

Patch release notes for Workarea 3.3.10.

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

## Update Tests to Pass Under MongoDB 3.6 and 4.0

The default order of related documents changed in **MongoDB 3.6**, so
the `Workarea::DataFile::TaxTest` needs to grab specific records rather
than rely on the order of elements in the returned collection. This is
the **first step** toward a full upgrade of the platform to take
advantage of later MongoDB versions, but at this time we do not
recommend running anything higher than **MongoDB 3.4** in production.
That said, this update allows one to run a higher MongoDB version in
development, and not have to lock their workstation down to an older
version.

### Issues

- [ECOMMERCE-6358](https://jira.tools.weblinc.com/browse/ECOMMERCE-6358)

### Pull Requests

- [3594](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3594/overview)

### Commits

- [4677a9454305f517ab8a8ac3f3b22059c8dc418f](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/4677a9454305f517ab8a8ac3f3b22059c8dc418f)


