---
title: Workarea 3.4.12
excerpt: Patch release notes for Workarea 3.4.12.
---

# Workarea 3.4.12

Patch release notes for Workarea 3.4.12. This is Workarea's first public
release! As such, there are some larger changes worth noting when upgrading.
Please read all these notes before updating your Gemfile!

## Remove hardcoded ignored Rack::Attack IP addresses

Workarea out-of-the-box Rack::Attack configuration had hardcoded IP addresses
for our offices and AlertLogic. Those have been removed and replaced with an
ENV variable to configure it. Use `WORKAREA_RACK_ATTACK_IGNORE_IP_ADDRESSES` to
specify ignored IP addresses like `WORKAREA_RACK_ATTACK_IGNORE_IP_ADDRESSES=192.168.2/24,172.16.254.1`

## Updated seed data

To add a better demo and public-facing sample data, some of the seed data for
Workarea has been reworked. You'll want to use pay special attention to the diff
when using the upgrade tool if you've customized the seed data.

## Removal of the workarea-ci gem

This gem was written specifically for the Workarea Commerce Cloud hosting, so
it doesn't make much sense for the public version. We've removed this gem from
the repository. The gem is still available on the Workarea gem server, so all
you need to do is add `gem 'workarea-ci'` to your Gemfile after upgrading.


## Display Relevant Flash Message When No Shipping Options Are Available

Improve the user experience when checkout cannot complete due to the
site having no available shipping options for the user's shipping
address.

### Issues

- [ECOMMERCE-6992](https://jira.tools.weblinc.com/browse/ECOMMERCE-6992)

### Pull Requests

- [4166](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4166/overview)

## Disallow Negative Prices in Seed Data

It was formerly possible to generate a `Pricing::Price` that had a
negative value in seeds. The `ProductsSeeds#perform` method now protects
against this.

### Issues

- [ECOMMERCE-7062](https://jira.tools.weblinc.com/browse/ECOMMERCE-7062)

### Pull Requests

- [4167](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4167/overview)

## Remove Test for Active Prices in Locale

This test did not pass in the real world when new locales are added.
Previously, `I18n.for_each_locale` did not iterate over all locales because
the locale was added to the wrong configuration setting. The test was
updated to use `Rails.application.config.i18n` to better simulate what
is used in the real world, but it was soon discovered that i18n
fallbacks work in a very strange way compared to the rest of the gem.
Because we can't guarantee that we need to include the `I18n::Backend::Fallbacks`
module at the time of app initialization, we can't guarantee that
fallbacks will be supported in the `Pricing::SkuTest`, so `#test_active_prices`
has been removed for the time being. This test was mostly ensuring the
functionality of i18n fallbacks rather than how our system handles them.

Discovered by **Devan Hurst** of Bounteous. Thanks Devan!

### Issues

- [ECOMMERCE-7013](https://jira.tools.weblinc.com/browse/ECOMMERCE-7013)

### Pull Requests

- [4172](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4172/overview)

## Filter Blank Data From All Reports

When using a `$divide` operation in a MongoDB aggregation, neither
number can equal 0 otherwise Mongo will throw an `OperationFailure`
error. This has been avoided by filtering out any records where numbers
that we divide are zero across the board. This error can typically
happen when first developing an application. In addition, the
unneeded `SearchesWithoutResults` report has been removed.

### Issues

- [ECOMMERCE-7016](https://jira.tools.weblinc.com/browse/ECOMMERCE-7016)
- [ECOMMERCE-7036](https://jira.tools.weblinc.com/browse/ECOMMERCE-7036)

### Pull Requests

- [4137](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4137/overview)
- [4164](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4164/overview)

## Fix Order Status Lookup Route

The `/orders/status/:order_id/:postal_code` was being resolved by the
`#show` action of OrdersController, when it really should be served by
`#lookup`. Change the route and add a test ensuring that the route is
being handled properly.

Discovered by **Andy Sides** of BVAccel. Thanks Andy!


### Issues

- [ECOMMERCE-7040](https://jira.tools.weblinc.com/browse/ECOMMERCE-7040)

### Pull Requests

- [4153](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4153/overview)

## Render Shipping Details Append Point On Index

Move the **admin.shipping_details** append point from `shippings#show`
(which is no longer rendered) over to `shippings#index`. Remove the
`shippings#show` partial to reduce confusion since it is no longer being
used.

### Issues

- [ECOMMERCE-7061](https://jira.tools.weblinc.com/browse/ECOMMERCE-7061)

### Pull Requests

- [4160](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4160/overview)

## Fix Internal Server Error Page Not Rendering JSON

When an Internal Server Error is requested via `/500.json`, another
error occurs when attempting to render the view for that request,
because there's no `internal` template. This is not how our error
handler is supposed to work, any format should be acceptable to render a
404 or 500. The syntax of the `respond_to` block in `#render_error_page`
has been altered so that Workarea serves the custom content HTML when an
HTML error occurs (e.g., most user-facing browser errors), and an empty
body with a 500 error in the status code is returned for all other
formats.

### Issues

- [ECOMMERCE-7034](https://jira.tools.weblinc.com/browse/ECOMMERCE-7034)

### Pull Requests

- [4156](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4156/overview)
