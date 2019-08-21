---
title: Workarea 3.2.35
excerpt: Patch release notes for Workarea 3.2.35.
---

# Workarea 3.2.35

Patch release notes for Workarea 3.2.35.

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

