---
title: Upgrading from Workarea v3.4 to v3.5
excerpt: A catalog of changes to watch out for while upgrading between minor versions
---

# Upgrading from Workarea v3.4 to v3.5

This document is intended to help ease your upgrade between minor versions of Workarea.

## Change releases to undo using new releases

### What's Changing?

Undoing a release in versions up to v3.5 was a separate code and Sidekiq job to revert the changes made based on a time specified on the release. To setup releases for more capabilities going forward (like segments and A/B testing), we're moving the release undo functionality to actually be a workflow to create mirrored, reverting release. The new undo release has a publish like any other, and can be edited like any other. This allows administrators to resolve conflicts and make other edits to the undo with full control.

### What Do You Need to Do?

We've written a migration script to move all future release-undoing to a set of new undo releases. This will build the reverting release changes and schedule those releases to the time the original ones were set to undo. It will also reindex releases in the admin so this is reflected. To run this, simply run `bin/rails workarea:migrate:v3_5` after you deploy.

## Release publishing has its own queue

### What's Changing?

To make release publishing as reliable and possible within Sidekiq, v3.5 adds a new queue as the highest priority. It's called `releases`.

### What Do You Need to Do?

If you're relying on the autoconfig of Sidekiq that Workarea provides, you don't have to do anything. If you are (probably with a `config/sidekiq.yml`), you'll want to add the queue `releases` to the top of the list.

## Schema.org structured data as JSON-LD

### Conversion of Microdata to JSON-LD format

[Schema.org](https://schema.org) structured data was previously represented in microdata format. This format enforced metadata attributes to be placed on relevant elements in views across the Storefront. The problem with this approach is that a developer will frequently edit markup to satisfy project requirements and can unwittingly cause the metadata to become invalid.

**Beginning in Workarea v3.5 we remove microdata from all Storefront views, favoring the recommended JSON-LD format** for which the following helpers have been written:

* `Workarea::SchemaOrgHelper`
* `Workarea::Storefront::SchemaOrgHelper`

**Switching from the microdata format to the JSON-LD format is not mandatory** as valid microdata is still an accepted format. It is, however, highly recommended that apps are upgraded to use the new format, as views that have not been overridden in the app will automatically begin using the new format. Offering a mixture of both microdata and JSON-LD is not recommended.


### Removal of Storefront product price partial

The conversion of the Schema.org structured data also rendered the `workarea/storefront/product/price` partial obsolete, as its primary purpose was to assist with the rendering of Schema.org Product Offer schema at the price level.

The contents of this partial are now directly rendered within the `workarea/storefront/product/pricing` partial itself.

### Additional Notes

These changes will be caught and displayed via the diffing functionality of the [Upgrade plugin](https://stash.tools.weblinc.com/projects/WL/repos/workarea-upgrade/browse).

### Relevant links:

* [Pull request](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3926/overview)
* [JIRA ticket](https://jira.tools.weblinc.com/browse/ECOMMERCE-6743)


## Updates to Headless Chrome Configuration

### What's Changing?

To accommodate future on-demand changes related to Chrome's auto-updating, we're renaming a Workarea configuration and adding a new one. The names now more accurately reflect how they're used.

### What Do You Need to Do?

If you're using `Workarea.config.headless_chrome_options`, you'll need to rename that to `Workarea.config.headless_chrome_args`. Some applications setup with Docker for local development will be affected by this.

## Updates tax rates with different tax level percentages

### What's Changing?

Tax rates up to v3.5 stored a single percentage that represented an estimated combined tax rate for all sales tax levels (country, state, county, etc.). Moving forward, tax rates store a separate percentage for each country, region, and postal code. This fixes potential inaccuracies in rounding tax amounts to better represent the tax to be collected in comparison to external systems.

### What Do You Need to Do?

We've written a migration script to move all tax rate percentages to the `postal_code_percentage` field. This will allow your application to continue to function as it did in v3.4. To run this, simply run `bin/rails workarea:migrate:v3_5` after you deploy. For better accuracy, consider reimporting tax rates with separate percentages for each tax level.

## Cookies/Session Refactored

### What's Changing?

We've cleaned up and consolidated the mess of cookies Workarea has been using to track everything from authentication to current order to impersonation. This makes expirations a lot easier to understand, and reduces the total size of cookies being passed between the server and client. In v3.5, the current order is stored in a permanent cookie (formerly in session), and anything authentication-related is stored in session (formerly in cookies). We've written it to move the values as needed automatically, so no need to worry about lost carts when you deploy the upgrade.

### What Do You Need to Do?

You'll need to switch references to their updated values:

* Update references to `cookies.signed[:user_id]` to `session[:user_id]`.
* Update references to `session[:order_id]` to `cookies.signed[:order_id]`.

You'll also need to check out your `config/initializer/session_store.rb` and ensure a sensible value for expiration. We'd recommend 30 minutes.

## Digital product behavior updated

### What's Changing?

We looked to offer more robust features around digital products in v3.5. As a result, `Fulfillment::Sku` was introduced as a way to define how each SKU is fulfilled. Each Fulfillment SKU has a policy, much like Inventory SKUs, that define what should be done upon the completion of checkout for an item of a particular SKU. By default there are 2 policies: ignore and download. Ignore will do nothing automatically, thus signifying that human intervention is needed in order to fulfill the item. This will be the default and most common policy. The download policy provides enhance functionality for digital items. Admin can associate a file to a Fulfillment SKUs with a download policy, which will automatically generate a unique token for purchase that gives the user access to a download link in the summary of their order after completion and any time after that from their order history. Each policy defines any automated behavior, and whether SKUs with the policy require shipping. This allows flexibility to have some automation but still require human intervention to fully fulfill the item.

As a part of this process, the `digital?` flag on products was no longer necessary. The field is still defined, but is no longer used anywhere within the base system and will be removed completely in future versions. Instead, this concern was shifted fully to `Fullfillment::Sku`. A stop-gap policy of `ignore_digital` was also provided to mimic the behavior a product not requiring shipping, but not having automated fulfillment.

### What Do You Need To Do?

The v3.5 migration script creates `Fulfillment::Sku` records for existing digital items, setting their policy to `ignore_digital`. This should preserve any behavior in your system for digital products. However, we strongly recommend reworking any code that relies on the `digital?` method of either `Catalog::Product` or `Order::Item`. Instead use `requires_shipping?` on `Order` and `Order::Item` to determine behaviors within this concern.

## Move Storefront Search Autocomplete Functionality to Plugin

### What's Changing?

We've removed the default Search Autocomplete functionality from the Storefront into a plugin to be able to give applications more flexibility.

### What Do You Need To Do?

To keep this functionality present in your application you'll need to install the `workarea-classic_search_autocomplete` plugin. 
