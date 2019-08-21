---
title: Workarea 3.0.64
excerpt: Patch release notes for Workarea 3.0.64.
---

# Workarea 3.0.64

Patch release notes for Workarea 3.0.64.

## Update GeoIP Headers to Latest Version

For apps that are using the [GeoIP 2 database](https://www.maxmind.com/en/geoip2-databases),
the headers have changed to a slightly different syntax, and some of them output
different values than they used to. Update `Workarea::Geolocation` to
handle both versions of the GeoIP database and to look up the
subdivision code by its name through the Countries gem.

### Issues

- [ECOMMERCE-7015](https://jira.tools.weblinc.com/browse/ECOMMERCE-7015)

### Pull Requests

- [4132](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4132/overview)

