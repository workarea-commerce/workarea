---
title: Workarea 3.3.27
excerpt: Patch release notes for Workarea 3.3.27.
---

# Workarea 3.3.27

Patch release notes for Workarea 3.3.27.

## Ensure Consistent Type and Case When Finding Tracking Number

`Fulfillment#find_tracking_number` was previously case-sensitive and did
not compare other data types. Ensure that the tracking number passed in
and each one from all packages are of a String type, and case-compared
so different casing does not affect matching.

### Issues

- [ECOMMERCE-6870](https://jira.tools.weblinc.com/browse/ECOMMERCE-6870)

### Pull Requests

- [4006](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4006/overview)

## Improve Bulk Edit Publish With New Release UI

This UI was rendering slightly incongruent with the rest of the
application. It has been changed to work in more circumstances.

### Issues

- [ECOMMERCE-6914](https://jira.tools.weblinc.com/browse/ECOMMERCE-6914)

### Pull Requests

- [4036](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4036/overview)

## Fix Product Categorization With Missing Indexes

When the Storefront index is missing,
`Search::Storefront::Product.find_categories` throws an exception due to
the **400 Bad Request** error it receives from the Elasticsearch server.
To prevent this and any other strange Elasticsearch errors from
affecting this method (which is not supposed to throw an exception),
rescue the base `Elasticsearch::Transport::Transport::ServerError` class
rather than any subclasses we find are thrown during this request.

### Issues

- [ECOMMERCE-6850](https://jira.tools.weblinc.com/browse/ECOMMERCE-6850)

### Pull Requests

- [4029](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4029/overview)

## Fix Exports Index Not Displaying After Promo Code Export

When a list of promo codes is exported, the data file exports index page
had trouble rendering a link to the collection, since there's no index
page for promo codes. Workarea will now render the non-linked name of
the object being exported, instead of attempting to generate a URL that
doesn't exist.

### Issues

- [ECOMMERCE-6911](https://jira.tools.weblinc.com/browse/ECOMMERCE-6911)

### Pull Requests

- [4033](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4033/overview)

## Add CI Scripts for Bamboo to the App Template

Create the `script/*` files used in Bamboo CI when a new application is
generated.

### Issues

- [ECOMMERCE-6908](https://jira.tools.weblinc.com/browse/ECOMMERCE-6908)

### Pull Requests

- [4023](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4023/overview)

## Fix Headless Chrome Randomly Dropping Cookies In System Tests

System tests were frequently failing during checkout after the
order went blank. This was caused by the session being lost due
to headless chrome not persisting the cookies. Passing
`--enable-features=NetworkService,NetworkServiceInProcess` as a headless
Chrome option fixes this behavior.

**More Information:** https://bugs.chromium.org/p/chromedriver/issues/detail?id=2897#c4

### Issues

- [ECOMMERCE-6929](https://jira.tools.weblinc.com/browse/ECOMMERCE-6929)

### Pull Requests

- [4046](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4046/overview)

## Fix Date/DateTime Picker UIs Default Setting on Page Load

Due to the issues outlined
[here](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date#Timestamp_string)
Workarea cannot accurately set a default date, on page load, for date
or datetime pickers for all browsers. To get as close as possible,
Workarea now picks just the date out of the Ruby timestamp string and
uses that as the basis for the datepicker default date UI.

### Issues

- [ECOMMERCE-6909](https://jira.tools.weblinc.com/browse/ECOMMERCE-6909)

### Pull Requests

- [4025](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4025/overview)

## Omit Blank Sorts From Product Search Index

Sorts configured in the product entries in Elasticsearch could
potentially get quite long and unruly if the product was categorized in
many places, but not set up for sorting in those categories. This causes
an error in Elasticsearch if allowed to grow out of control, since its
field limit for a single document is 1000. Workarea now removes any
categories in the `sorts` for which a product position in `product_ids`
cannot be found. This reduces the amount of noise in the documents and
prevents scaling errors like this one.

### Issues

- [ECOMMERCE-6912](https://jira.tools.weblinc.com/browse/ECOMMERCE-6912)

### Pull Requests

- [4032](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4032/overview)

