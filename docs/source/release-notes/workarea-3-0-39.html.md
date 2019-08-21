---
title: Workarea 3.0.39
excerpt: Patch release notes for Workarea 3.0.39.
---

# Workarea 3.0.39

Patch release notes for Workarea 3.0.39.

## Add Indexes for Uniquely-Validated Fields

There are a number of places, namely `Catalog::Category`,
`Content::Email`, and `Navigation::Taxon`, that were missing indexes and
thus resulted in a full table scan upon validation of their unique
values. In most cases this is inconsequential to page load times, but in
larger deployments this scan can pose a problem when attempting to save
these items from the admin. Therefore, unique indexes have been added to
all fields that are validated for uniqueness out of the box, in order to
mitigate this problem on future deployments.

### Issues

- [ECOMMERCE-6119](https://jira.tools.weblinc.com/browse/ECOMMERCE-6119)

### Pull Requests

- [3511](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3511/overview)
- [3530](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3530/overview)

### Commits

- [5e3f506be9ed85ee32ff780509b8df151984f942](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/5e3f506be9ed85ee32ff780509b8df151984f942)
- [0e6f6426a20d2fa61cf3c13cd4812fb8df8d3d64](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/0e6f6426a20d2fa61cf3c13cd4812fb8df8d3d64)

## Handle Missing Geocoder Data For Bogus IP Addresses

In certain environments (like Docker), IP addresses are not guaranteed to
be valid, thus a `Geocoder` response has the potential of returning
invalid data for the `Geolocation#coordinates` method. This method now
returns `nil` if geolocation fails for the IP, and GeoIP headers are not
present, so plugins like `workarea-store_locations` which consume this
API will not have to make any changes 

### Issues

- [ECOMMERCE-6233](https://jira.tools.weblinc.com/browse/ECOMMERCE-6233)

### Pull Requests

- [3525](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3525/overview)

### Commits

- [61ae019317de30651943e6b5d6f728c97236c3e6](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/61ae019317de30651943e6b5d6f728c97236c3e6)

## Fix Previewing Future Navigation Menu Changes

Changes to the navigation menu order (and activity) are now visible when
previewing a future release. To achieve this, the `#navigation_menus`
helper sorts the collection returned from the database by its
`#position`, which (unlike a bare DB query) is affected by the release
changes. Previously this was just running a database query, which would
not account for the changes that occur within a release.

### Issues

- [ECOMMERCE-6219](https://jira.tools.weblinc.com/browse/ECOMMERCE-6219)

### Pull Requests

- [3520](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3520/overview)

### Commits

- [d4084d4d6f15c2b251526fb8c786acb780b066a0](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/d4084d4d6f15c2b251526fb8c786acb780b066a0)


