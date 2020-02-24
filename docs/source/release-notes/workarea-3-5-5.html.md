---
title: Workarea 3.5.5
excerpt: Patch release notes for Workarea 3.5.5.
---

# Workarea 3.5.5

Patch release notes for Workarea 3.5.5.

## Expose Shipping Service Code in Admin

The shipping service code is now editable on the shipping service new/edit forms.

### Pull Requests

- [318](https://github.com/workarea-commerce/workarea/pull/318)

## Don't Store Content Block Type Definitions in App Configuration

Storing these in `Workarea.config` breaks when combined with the
multisite plugin because `Workarea.config` gets copied to the site as
part of the creating the site. Since creating the site happens during
initialization and the blocks typesaren't set on `Workarea.config`, you
end up with an empty configuration for block types. Workarea now stores
this information outside of the global app configuration to prevent this
issue from occurring.

**More Info:** https://discourse.workarea.com/t/multi-site-and-testing/1778/3

### Pull Requests

- [360](https://github.com/workarea-commerce/workarea/pull/360)

## Fix TrafficReferrerTest on Ruby 2.4 and Below

It turns out that `TrafficReferrerTest` won't pass on Ruby 2.4 because
of the way `#casecmp?` works in 2.5 and above. The test syntax has been
updated to work with Ruby 2.4 and below.

### Pull Requests

- [354](https://github.com/workarea-commerce/workarea/pull/354)

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

