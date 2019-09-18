---
title: Workarea 3.5.0 Release Notes
excerpt: Release notes for Workarea 3.5.0
---

Workarea 3.5.0 Release Notes
======================================================================

__Upgrading to Workarea 3.5?__ See also [Workarea 3.5.0 Upgrade Guide](/upgrade-guides/workarea-3-5-0.html) and [Workarea Upgrade](https://plugins.workarea.com/plugins/upgrade).

Workarea 3.5 improves releases and introduces segmentation to the base platform.
The accuracy of release previews has improved in several ways. Most notably, all releases scheduled to publish before the previewed release are reflected in the preview.
Workarea 3.5 also introduces segments, segment-based metrics and insights, and per-segment activeness.
To facilitate segmentation, sessions and cookies have been refactored.

This release also improves platform support for digital products, introducing the concepts of fulfillments SKUs and fulfillment policies.
Payment can now be collected differently based on an order's contents (e.g. capture immediately for digital products), and an infrastructure for fraud analysis has been added.

Also new is access to some configuration values in the Admin and administration of tax rates.

The sections below provide details and these and other changes.
For all changes, see the [changelog](https://github.com/workarea-commerce/workarea/blob/master/CHANGELOG.md).


Major Features / Changes
----------------------------------------------------------------------

### Releases

* Improves release previewing by including all releases scheduled to publish before the previewed release
* Removes release undo functionality in favor of using separate "undo" releases, and adds a workflow for creating them
* Restores the releases calendar feature in the Admin
* Allows data file importing in releases
* Allows rules changes in releases
* Allows accurate previewing of featured product changes in releases
* Adds a separate Sidekiq queue for releases
* Changes how releases are represented in Elasticsearch

[3954](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3954/overview),
[3982](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3982/overview),
[3996](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3996/overview),
[4021](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4021/overview),
[4092](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4092/overview),
[4125](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4125/overview),
[4157](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4157/overview),
[44](https://github.com/workarea-commerce/workarea/pull/44)


### Segmentation

* Adds segmentation feature to the base platform
* Adds segment-based metrics and insights
* Adds per-segment activeness to allow segmented site experiences

[4055](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4055/overview),
[4095](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4095/overview)


### Sessions

* Refactors session and cookies
* Tracks sessions in metrics for segmentation

[4129](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4129/overview),
[35](https://github.com/workarea-commerce/workarea/pull/35)


### Digital Products

* Adds concept of fulfillment SKU
* Deprecates `digital` field on products
* Allows capturing payment for digital items when the order is placed

[4142](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4142/overview),
[4119](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4119/overview),
[4123](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4123/overview)


### Payment & Fraud

* Changes checkout to adjust tender amounts throughout
* Changes configuration of and logic for payment collection
* Adds infrastructure for fraud analysis (see [Add a Fraud Analyzer](/articles/add-a-fraud-analyzer.html))
* Allows restricting checkout to certain credit card brands

[3951](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3951/overview),
[4119](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4119/overview),
[4103](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4103/overview),
[4123](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4123/overview)


### Administrable Configuration

* Allows administration of some configuration values
* Includes encrypted fields
* See [Configuration Fields](/articles/configuration-fields.html)

[4017](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4017/overview),
[4053](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4053/overview),
[4064](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4064/overview),
[4079](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4079/overview),
[4090](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4090/overview),
[4109](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4109/overview),
[4124](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4124/overview),
[49](https://github.com/workarea-commerce/workarea/pull/49)


### Tax Rates UI

* Allows defining separate values for country, region and postal code tax rates
* Allows editing tax rates in the Admin
* See [Taxes](/articles/taxes.html)

[4101](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4101/overview),
[4124](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4124/overview),
[4112](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4112/overview)


Minor Features / Changes
----------------------------------------------------------------------

* __Admin Emails__:
  Redesigns Admin emails.
  Allows unsubscribing from Admin email.
  [3994](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3994/overview),
  [4165](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4165/overview)
* __Reports__:
  Adds "sales by tender" and "timeline" reports.
  Adds metrics for order cancellations.
  [3933](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3933/overview),
  [4048](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4048/overview)
  [3975](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3975/overview)
* __Featured Products Admin UI__:
  Refactors inventory status, adding the concept of inventory collection status.
  Adds inventory status to featured products Admin UI.
  [3957](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3957/overview),
  [3983](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3983/overview)
* __Content Block Asset Alt Text__:
  Allows the alt text of a content block asset to fall back to the alt text stored on the content asset.
  [3988](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3988/overview),
  [4130](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4130/overview)
* __Admin Access to Password Resets and Locked Logins__:
  Allows administrators to unlock logins and send password resets from the Admin.
  [3955](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3955/overview),
  [3956](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3956/overview)
* __Admin Impersonation UI__:
  Adds indicator to Admin UI when impersonating another user.
  [3910](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3910/overview)
* __Discount Redemptions Admin__:
  Adds a "redemptions" card to the discounts admin.
  [3993](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3993/overview)
* __Admin Order Permissions__:
  Adds separate permission for management of orders.
  [3991](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3991/overview)
* __Search Autocomplete__:
  Moves search autocomplete from the base platform into two plugins:
  [Workarea Search Autocomplete](https://github.com/workarea-commerce/workarea-search-autocomplete) and
  [Workarea Classic Search Autocomplete](https://github.com/workarea-commerce/workarea-classic-search-autocomplete).
  [18](https://github.com/workarea-commerce/workarea/pull/18)
* __JSON-LD Schema.org Data__:
  Replaces Schema.org microdata with Schema.org JSON-LD throughout the Storefront.
  Adds Schema.org data to emails.
  [3920](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3920/overview)
* __Configuration in Test Environment__:
  Resets the configuration after each test.
  [3892](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3892/overview)
* __Headless Chrome Configuration__:
  Changes default options for headless Chrome and allows passing additional arguments.
  [4080](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4080/overview)
* __Content Block DSL__:
  Deprecates `Workarea::Content.define_block_types` in favor of `Workarea.define_content_block_types`.
  [4082](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4082/overview)
* __Sidekiq Query Cache Middleware__:
  Adds additional Sidekiq option.
  Improves search indexing performance.
  [48](https://github.com/workarea-commerce/workarea/pull/48)
