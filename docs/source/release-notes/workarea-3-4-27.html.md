---
title: Workarea 3.4.27
excerpt: Patch release notes for Workarea 3.4.27.
---

# Workarea 3.4.27

Patch release notes for Workarea 3.4.27.

## Expose Shipping Service Code in Admin

The shipping service code is now editable on the shipping service new/edit forms.

### Pull Requests

- [318](https://github.com/workarea-commerce/workarea/pull/318)

## Remove Changes Count in Releases Index

For applications that have a large amount of releases, counting all release
changesets that hadn't been removed caused major performance problems on the
tabular releases index in admin. To prevent this, Workarea no longer shows the
changesets pointing to non-deleted items, as there is no way to make this query
any faster.

### Pull Requests

- [368](https://github.com/workarea-commerce/workarea/pull/368)

## Fix Display of Prices on Pricing SKUs Index in Admin

When a pricing SKU was considered on sale, the index page would render the sale
price in the "Regular Price" column. Since this is no longer an accurate
depiction of the prices that may be contained in the SKU, the "Regular Price"
and "Sale Price" columns have been replaced by a single "Sell Price" column
that shows a range of either sale or regular prices depending on whether the
SKU is considered on sale.

### Pull Requests

- [369](https://github.com/workarea-commerce/workarea/pull/369)

## Fix S3 CORS overwriting

Workarea previously replaced the existing CORS configuration on the S3
bucket used for storing direct uploads with its own, which caused issues
for environments that share an S3 bucket between servers (such as ad-hoc
demo servers or low-traffic "all-in-one" instances). Instead of
replacing the entire configuration, Workarea now reads the existing
allowed hosts configuration and appends its own onto the end, preserving
the configuration that previously existed. This should address the
problem wherein if another server attempts a direct upload, it can
revoke the access from previous servers to upload to the S3 bucket,
since they were no longer in the CORS configuration.

### Pull Requests

- [358](https://github.com/workarea-commerce/workarea/pull/358)
- [367](https://github.com/workarea-commerce/workarea/pull/367)

## Handle Deleted Categories in Category Options

In the `options_for_category` method, Workarea did not previously check
for whether a category exists, resulting in Mongoid throwing a
`DocumentNotFound` error when encountering the method and causing a 500
error in the real world. This has now been resolved by rewriting the
code to check for whether the model was found before proceeding.
`options_for_category` will now return `nil` early when this occurs.

### Pull Requests

- [359](https://github.com/workarea-commerce/workarea/pull/359)


## Add Append Point for Post-Subtotal Adjustments

This adds an append point right underneath the order subtotal and above
the shipping total in the admin order attributes view.

### Pull Requests

- [316](https://github.com/workarea-commerce/workarea/pull/316)

