---
title: Workarea 3.4.11
excerpt: Patch release notes for Workarea 3.4.11.
---

# Workarea 3.4.11

Patch release notes for Workarea 3.4.11.

## Improve Accuracy of CSV Import Encoding Test

The unit test written for configuring the charset of any CSV files
imported into the system was not accurate, as it was not actually
testing what would happen if the configuration was in place. The test
continued to pass, however, because the String being used as the CSV
text was inherently UTF-8, as is the default in Ruby. To fix this, the
test now includes hard-coded ASCII characters in order to simulate a
mixed encoding, which throws the right error when the code that fixes
this bug is removed.

### Issues

- [ECOMMERCE-7012](https://jira.tools.weblinc.com/browse/ECOMMERCE-7012)

### Pull Requests

- [4134](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4134/overview)

## Support Plural Class Names When Loading Report Class

The use of `#classify` causes errors to be thrown during export of
a report class that is plural, e.g. WishListProducts. This causes
the export to fail and the user to not receive the export email. To
resolve this, Workarea now uses `#camelize` to preserve the plurality of
the report class name.

### Issues

- [ECOMMERCE-7032](https://jira.tools.weblinc.com/browse/ECOMMERCE-7032)

### Pull Requests

- [4143](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4143/overview)

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

