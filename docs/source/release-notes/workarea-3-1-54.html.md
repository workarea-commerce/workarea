---
title: Workarea 3.1.54
excerpt: Patch release notes for Workarea 3.1.54.
---

# Workarea 3.1.54

Patch release notes for Workarea 3.1.54.

## Remove BSON Gem Restriction

Newer versions of the `mongo` gem contain fixes for using MongoDB clusters,
which are used by Commerce Cloud to maintain high-availability database servers
for our customers. Removing this dependency on the `bson` gem, which originally
addressed a security concern in our application, allows upgrading the MongoDB
Ruby drivers to support this new functionality.

### Pull requests

- [4181](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4181/overview)
