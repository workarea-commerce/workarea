---
title: Workarea 3.1.18
excerpt:  The return value of Payment::Profile.lookup with the same or similar PaymentReferences as the argument was not always consistent. In some cases, Payment::Profile.lookup returns an invalid record, which causes problems down the line when an OMS or som
---

# Workarea 3.1.18

## Fix payment profile discrepancies

The return value of `Payment::Profile.lookup` with the same or similar `PaymentReference`s as the argument was not always consistent. In some cases, `Payment::Profile.lookup` returns an invalid record, which causes problems down the line when an OMS or something needs to read information stored in the profile record, and now that record cannot be found. What is actually happening is that the profile _was_ successfully created, but `.lookup` is not written to use the pre-existing profile and instead tries to generate a new one. When this fails, when we get issues like the `Payment#profile_id` referencing a record that doesn't actually exist. To remedy this, we've updated how `Payment::Profile.lookup` works to always find by the `PaymentReference#id`, and automatically update email if we're creating a new record.

### Issues

- [ECOMMERCE-5947](https://jira.tools.weblinc.com/browse/ECOMMERCE-5947)

### Pull Requests

- [3284](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3284)
- [3282](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3282)

### Commits

- [b4ac7fe2a1c07f03db42af770339d8219e607518](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b4ac7fe2a1c07f03db42af770339d8219e607518)
- [e74ec054739995c2433b09eebeb5b2b5dcae5f40](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/e74ec054739995c2433b09eebeb5b2b5dcae5f40)

## Daylight savings time is being accounted for twice in release calendar

Although the application server for Workarea applications has its global time zone configured, the Calendar view for releases will pick the time zone that the user is currently in and render dates/times in that particular locality. However, this caused issues when time zones were vastly different between client and server, wherein we discovered that daylight savings time was being factored into the time offset twice, both on the client-side by JavaScript and on the server-side by Rails' time zone enhancements to Ruby. This has been fixed by always specifying the standard timezone offset, and then based on DST, reconciling in the extra hour lost/gained on the server-side only.

### Issues

- [ECOMMERCE-5836](https://jira.tools.weblinc.com/browse/ECOMMERCE-5836)

### Pull Requests

- [3258](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3258)

### Commits

- [830922c6a47ac13c6d99b1e603404b7915bdd6f5](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/830922c6a47ac13c6d99b1e603404b7915bdd6f5)

## Add .ui-menu-item-wrapper to jQuery UI menu template

This element was not included in the jQuery UI menu template for asynchronously adding a `.ui-menu-item` to the page, causing some issues in the handler code that jQuery UI gives us. Add the element to both fix the actual UI and behavior of jQuery UI menu items.

### Issues

- [ECOMMERCE-5958](https://jira.tools.weblinc.com/browse/ECOMMERCE-5958)

### Pull Requests

- [3292](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3292)

### Commits

- [78f98837efa44b9835bd860c0eec58eb847fca52](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/78f98837efa44b9835bd860c0eec58eb847fca52)

## Convert IDs to string when comparing in find\_ordered

Our `find_ordered` method did not work as intended when the type of each document's `#id` were not consistent. Convert all IDs to String before comparing them to gain a more accurate sorted Array out of this method.

### Issues

- [ECOMMERCE-5011](https://jira.tools.weblinc.com/browse/ECOMMERCE-5011)

### Pull Requests

- [3278](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3278)

### Commits

- [61925ad6e51c9b3552f423a3c2d2d98e970405b6](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/61925ad6e51c9b3552f423a3c2d2d98e970405b6)

