---
title: Workarea 3.2.43
excerpt: Patch release notes for Workarea 3.2.43.
---

# Workarea 3.2.43

Patch release notes for Workarea 3.2.43.

## Remove BSON Gem Restriction

Newer versions of the `mongo` gem contain fixes for using MongoDB clusters,
which are used by Commerce Cloud to maintain high-availability database servers
for our customers. Removing this dependency on the `bson` gem, which originally
addressed a security concern in our application, allows upgrading the MongoDB
Ruby drivers to support this new functionality.

### Pull Requests

- [4181](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4181/overview)

## Update Mongoid to v6.4

This will ensure tests pass with the latest version of the `mongo` gem.

### Commits

- [c48d66436c89ded7011970b974dc4000add2acee](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c48d66436c89ded7011970b974dc4000add2acee)
