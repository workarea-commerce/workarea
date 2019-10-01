---
title: Workarea 3.4.17
excerpt: Patch release notes for Workarea 3.4.17.
---

# Workarea 3.4.17

Patch release notes for Workarea 3.4.17.

## Add Order Confirmation Append Point

Add the `storefront.checkout_confirmation_text` append point below the
`workarea.storefront.checkouts.confirmation_text` copy in storefront.

### Issues

- [76](https://github.com/workarea-commerce/workarea/issues/76)

### Pull Requests

- [76](https://github.com/workarea-commerce/workarea/pull/76)


## Prevent Error in Product Admin When There Are No Categories

`ProductViewModel#default_category` now protects against a `nil` value
for the default category before passing its value into a view model.
This caused an issue for a brand new install when no categories have
been added yet.

### Issues

- [33](https://github.com/workarea-commerce/workarea/issues/33)

### Pull Requests

- [55](https://github.com/workarea-commerce/workarea/pull/55)

## Improve display of referrer URLs on Orders Show view

Due to the length of URLs being displayed on Order Attributes in the admin
they will potentially break layout. Now they are displayed within a tooltip
behind a "View" link click. The resulting tooltip will prompt the user to
copy the contents of a text box containing the URL.

Fixes #60

### Issues

- [60](https://github.com/workarea-commerce/workarea/issues/60)

### Pull Requests

- [81](https://github.com/workarea-commerce/workarea/pull/81)


## Improve Plugin Template

The plugin template has been overhauled to work with open source-derived
Workarea code, and some additional fixes for plugin developers to make
things easier. A short list:

* Updates usage documentation at top of template
* Properly namespace directories under `app/assets`
* Set starting version to `1.0.0.pre`
* Point to HTTPS GitHub url instead of SSH
* Clean up generated README
* Add Business Software License as LICENSE
* Link license in gemspec and README
* Fix indentation and whitespace issues in `.gemspec` file
* Remove `script/` directory, since we now use GitHub Actions for CI
* Clean up generated `.gitignore`
* Fix link to developer documentation in README
* Fix flagrant quote fail for required Rails engines

### Issues

- [25](https://github.com/workarea-commerce/workarea/issues/25)

### Pull Requests

- [62](https://github.com/workarea-commerce/workarea/pull/62)


## Store Inverse Aspect Ratio on Dragonfly Models

Populate the `:image_inverse_aspect_ratio` automatically using
Dragonfly, in order to reduce the amount of requests made to S3 in order
to find out this information. This way, Dragonfly can store more assets
in the cache.

### Issues

- [116](https://github.com/workarea-commerce/workarea/issues/116)

### Pull Requests

- [118](https://github.com/workarea-commerce/workarea/pull/118)

## Prevent Duplicate Tags in Mongoid Models

When inserting tags into a taggable document, make sure their values are
unique. This addresses an issue where incorrect tag counts were being
displayed on the storefront.

### Issues

- [112](https://github.com/workarea-commerce/workarea/issues/112)

### Pull Requests

- [114](https://github.com/workarea-commerce/workarea/pull/114)


