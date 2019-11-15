---
title: Workarea 3.4.21
excerpt: Patch release notes for Workarea 3.4.21.
---

# Workarea 3.4.21

Patch release notes for Workarea 3.4.21.

## Remove BSON Gem Restriction

Newer versions of the `mongo` gem contain fixes for using MongoDB clusters,
which are used by Commerce Cloud to maintain high-availability database servers
for our customers. Removing this dependency on the `bson` gem, which originally
addressed a security concern in our application, allows upgrading the MongoDB
Ruby drivers to support this new functionality.

### Pull Requests

- [215](https://github.com/workarea-commerce/workarea/pull/215)

## Update `Redis::Rack::Cache` to v2.2.0

This new version requires `Rack::Cache` v1.10 and enables over-the-wire gzip
compression to the Redis server via the `:compress` option. This feature is
useful for extremely high traffic sites, but should be used with caution since
it will increase the CPU/RAM load on your application server. You should use
this if the trade-off between RAM increase and bandwidth decrease makes sense.

**If you're on Workarea Commerce Cloud, consult one of our technicians before
enabling this option.**

### Pull Requests

- [223](https://github.com/workarea-commerce/workarea/pull/223)

## Update Chartkick

Addresses an XSS vulnerability in the previous version.

More Info: https://github.com/ankane/chartkick/issues/488
CVE: https://github.com/advisories/GHSA-g45g-g52h-39rg

### Pull Requests

- [224](https://github.com/workarea-commerce/workarea/pull/224)

## Fix Services Task When Bundler Shell Fails

This can cause problems if bundler outputs warnings/errors. There's a safe way
to do it in Ruby, and Workarea now makes use of this method instead.

### Issues

- [191](https://github.com/workarea-commerce/workarea/issues/191)

### Pull Requests

- [192](https://github.com/workarea-commerce/workarea/pull/192)

## Handle Timestamps from CSV Imports Gracefully

Workarea will now serialize and deserialize timestamp objects from the CSV
imports into `Date` and `Time`, and prevent out-of-bounds dates from getting
into the system. To accomplish this, a check is performed prior to saving the
parsed timestamp and if the date appears to be before 1970 (the beginning of
[UNIX Epoch Time](https://en.wikipedia.org/wiki/Unix_time)), Workarea will
treat it as a `nil` value.

### Pull Requests

- [200](https://github.com/workarea-commerce/workarea/pull/200)
