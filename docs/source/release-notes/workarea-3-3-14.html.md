---
title: Workarea 3.3.14
excerpt: Patch release notes for Workarea 3.3.14.
---

# Workarea 3.3.14

Patch release notes for Workarea 3.3.14.

## Update App Template with Additional Configuration

Update defaults in the app template for NewRelic, Basic Auth, and app
tests. Adds NewRelic APM reporting in QA, a random basic auth password
by default, a simple assertion unit test to allow custom tests to
complete successfully in Bamboo, and the URI for Docker build images.

### Issues

- [ECOMMERCE-6440](https://jira.tools.weblinc.com/browse/ECOMMERCE-6440)

### Pull Requests

- [3652](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3652/overview)

### Commits

- [24be14692b2fef6cb235bc01e1d7a82fbf84d832](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/24be14692b2fef6cb235bc01e1d7a82fbf84d832)
- [ab7121c9635a89ecba16edb9e32cc0d853cf4a4d](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ab7121c9635a89ecba16edb9e32cc0d853cf4a4d)



## Prevent URL Change When Not Viewing Singular Details on PDP

When the given variant of a product changes as a result of a
`productDetailsSkuSelects`, the URL will no longer update unless
specifically triggered to via the `data-product-details-update-url`
attribute being set on the containing element
(`.product-details-container`). This fixes an issue whereby plugins
(like Quickview and Package Products) which render product details
outside of the PDP caused a URL update to happen that would make the URL
include query parameters which had nothing to do with the page/product
the user was browsing.

### Issues

- [ECOMMERCE-6400](https://jira.tools.weblinc.com/browse/ECOMMERCE-6400)

### Pull Requests

- [3639](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3639/overview)

### Commits

- [4aa482ad996b9ef854c4454fa7d0bb594498b254](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/4aa482ad996b9ef854c4454fa7d0bb594498b254)
- [96aa5831c37d42c9cf02b971c8c0c23e1e885836](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/96aa5831c37d42c9cf02b971c8c0c23e1e885836)

## Use HTTP DELETE Method For "Log Out" Link

Fixes issues logging out on some browsers. While Workarea still supports
the `GET /logout` route, `DELETE /logout` is the "canonical" means of
clearing one's Workarea session.

### Issues

- [ECOMMERCE-6465](https://jira.tools.weblinc.com/browse/ECOMMERCE-6465)

### Pull Requests

- [3669](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3669/overview)

### Commits

- [108379ca679204a8df0082ffb36a35693745eca0](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/108379ca679204a8df0082ffb36a35693745eca0)


## Fix Sidekiq Callbacks Not Running In Development Mode

In development mode, Rails code reloading caused a bug in
`Sidekiq::Callbacks` being able to detect when callbacks were being
fired by ActiveRecord, which caused them to not get performed at the
right times. Make this more consistent and enable caching to prevent
a loss in performance. In order to achieve this, Workarea also drops
support for the `after_find` callback in `Sidekiq::Callbacks`

### Issues

- [ECOMMERCE-6439](https://jira.tools.weblinc.com/browse/ECOMMERCE-6439)

### Pull Requests

- [3667](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3667/overview)
- [3662](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3662/overview)
- [3648](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3648/overview)

### Commits

- [528be5505a418611f7b706696075db9dcecd04b8](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/528be5505a418611f7b706696075db9dcecd04b8)
- [fcfc55e99e0ad17a3599933482d1f38e8749bce8](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/fcfc55e99e0ad17a3599933482d1f38e8749bce8)
- [93d55d98d229e1302b7e1558b2b02d8cb2737acc](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/93d55d98d229e1302b7e1558b2b02d8cb2737acc)
- [6e8d154b747084718863c8cef29a4cafaedff50b](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/6e8d154b747084718863c8cef29a4cafaedff50b)

## Support Redis 4+ in EasyMon

Bump the `easymon` gem to the newly-released 1.4 to support Redis 4+.

### Issues

- [ECOMMERCE-6449](https://jira.tools.weblinc.com/browse/ECOMMERCE-6449)

### Pull Requests

- [3655](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3655/overview)

### Commits

- [3afbe0e47f9f11560c8b17292ebb2a611d737924](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/3afbe0e47f9f11560c8b17292ebb2a611d737924)


## Ensure New Content Block Drafts Attach To An Area

Pass `area_id` to `BlockDraft` when a new content block is created.
Allows the `area_id` to be used to determine the preview layout for newly created blocks

### Issues

- [ECOMMERCE-6423](https://jira.tools.weblinc.com/browse/ECOMMERCE-6423)

### Pull Requests

- [3641](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3641/overview)

### Commits

- [1e478d73e8204117eab743538182defbc40236bb](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/1e478d73e8204117eab743538182defbc40236bb)


## Fix 12th-Hour Formatting in Admin DateTime Picker

Workarea's `dateTimePicker` incorrectly converted"12th hour (12:00pm and 12:00am) times
in `dateTimePickerFields` to 24-hour time upon submission. This has now
been resolved so releases appear at the correct times.

### Issues

- [ECOMMERCE-6462](https://jira.tools.weblinc.com/browse/ECOMMERCE-6462)

### Pull Requests

- [3657](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3657/overview)

### Commits

- [42d230005d3f9191ed0dcdd27b0b5b8841a90464](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/42d230005d3f9191ed0dcdd27b0b5b8841a90464)

## Prevent Redis Errors When Service Connections Are Skipped

When `$WORKAREA_SKIP_SERVICES` is set to "true" in the shell, some
configuration steps still attempt to call out to Redis and thus causes an error in
the application on boot. Ensure that `Workarea.config.skip_service_connections`
is evaluated before any outbound calls to Redis. This enables the use of
`$WORKAREA_SKIP_SERVICES` in Dockerized setups, as well as the ability
to develop Workarea applications without having Redis installed.

### Issues

- [ECOMMERCE-6412](https://jira.tools.weblinc.com/browse/ECOMMERCE-6412)

### Pull Requests

- [3663](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3663/overview)

### Commits

- [ecc75583c6654b4877ac1c361678d765502f2c04](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/ecc75583c6654b4877ac1c361678d765502f2c04)


## Rename "Facets" To "Filters" in Search Settings

In both category-specific and global search settings configuration, use
the word "Filters" to describe search filters, which is the way they are
describe it everywhere else in the application, rather than the more
technically-oriented "Facets".

### Issues

- [ECOMMERCE-6422](https://jira.tools.weblinc.com/browse/ECOMMERCE-6422)

### Pull Requests

- [3666](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3666/overview)

### Commits

- [2a016e314f82b49ffbb20557366254946eea9079](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/2a016e314f82b49ffbb20557366254946eea9079)


