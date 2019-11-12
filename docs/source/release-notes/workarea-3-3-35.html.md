---
title: Workarea 3.3.35
excerpt: Patch release notes for Workarea 3.3.35.
---

# Workarea 3.3.35

Patch release notes for Workarea 3.3.35.

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

## Update `Redis::Rack::Cache` to v2.2.0

This new version requires `Rack::Cache` v1.10 and enables over-the-wire gzip
compression to the Redis server via the `:compress` option. This feature is
useful for extremely high traffic sites, but should be used with caution since
it will increase the CPU/RAM load on your application server. You should use
this if the trade-off between RAM increase and bandwidth decrease makes sense.

**If you're on Workarea Commerce Cloud, consult one of our technicians before
enabling this option.**

### Pull Requests

- [4182](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4182/overview)
