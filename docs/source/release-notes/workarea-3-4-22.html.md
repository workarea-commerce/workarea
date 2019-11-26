---
title: Workarea 3.4.22
excerpt: Patch release notes for Workarea 3.4.22.
---

# Workarea 3.4.22

Patch release notes for Workarea 3.4.22.

## Use Correct Format to Download Data File Import Samples

Previously, Workarea would initiate a download of the sample using an incorrect
format type, which on some browsers resulted in the file not downloading at
all, instead being displayed in the browser. This was resolved by fixing the
MIME Type used to transfer the file in the first place.

### Pull Requests

- [240](https://github.com/workarea-commerce/workarea/pull/240)

## Handle BOM Characters In Data File CSV Imports

The [Byte Order Mark](https://en.wikipedia.org/wiki/Byte_order_mark) character
in UTF-8 documents is not handled by Ruby's default CSV encoding scheme. To
address this, the default `:encoding` option was changed to "bom|utf-8". The
BOM character can sometimes be included by spreadsheet software when editing a
CSV sample.

### Pull Requests

- [243](https://github.com/workarea-commerce/workarea/pull/243)

## Make Discount Auto-Deactivation Friendly To Releases

Workarea's discount auto-deactivation begins as soon as the discount is
created, resulting in issues if the discount isn't actually active yet. In some
cases, a released discount can be made auto-deactivated immediately after its
activation. This has been resolved by basing the time at which a discount was
active on the last updated at, rather than created at, timestamp. This causes
edits to the discount to "reset the timer" on auto-deactivation, and prevents
the aforementioned issue.

### Pull Requests

- [245](https://github.com/workarea-commerce/workarea/pull/245)

## Fix Content Block Asset Uploads

Set a Redis key to reduce unnecessary S3 CORS configuration requests.

### Pull Requests

- [248](https://github.com/workarea-commerce/workarea/pull/248)

## Update Test Assertions Referencing 2020

There are a few assertions in Workarea's test suite that reference a year of
2020 as a credit card expiry date. In order to prevent test issues on January
1st, 2020, update all relevant tests to always choose a year that's 1 year in
advance of the current date, to prevent this problem from happening in the
future.

### Pull Requests

- [239](https://github.com/workarea-commerce/workarea/pull/239)
