---
title: Workarea 3.5.0 Upgrade Guide
excerpt: Changes requiring attention when upgrading to Workarea 3.5.0
---

# Workarea 3.5.0 Upgrade Guide

---

__Upgrading to Workarea 3.5?__ &mdash; Check out the [Workarea 3.5 Release Notes](/release-notes/workarea-3-5-0.html)

---

Before upgrading to Workarea 3.5.0, review the following changes.
After upgrading you'll need to do the following:

* Run the data migration, `bin/rails workarea:migrate:v3_5`
* Create the new MongoDB indexes, `bin/rails db:mongoid:create_indexes`

## Change releases to undo using new releases

### What's Changing?

Undoing a release in versions up to v3.5 was separate code and a Sidekiq job to revert the changes made based on a time specified on the release. To set up releases for more capabilities going forward (like A/B testing), we're moving the release undo functionality to actually be a workflow to create a mirrored, reverting release. The new undo release has a publish like any other, and can be edited like any other. This allows administrators to resolve conflicts and make other edits to the undo with full control.

### What Do You Need to Do?

We've written a migration script to move all future release-undoing to a set of new undo releases. This will build the reverting release changes and schedule those releases to the time the original ones were set to undo. It will also reindex releases in the admin so this is reflected. To run this, simply run `bin/rails workarea:migrate:v3_5` after you deploy.

## Release publishing has its own queue

### What's Changing?

To make release publishing as reliable and possible within Sidekiq, v3.5 adds a new queue as the highest priority. It's called `releases`.

### What Do You Need to Do?

If you're relying on the autoconfig of Sidekiq that Workarea provides, you don't have to do anything. If you aren't (most likely using a `config/sidekiq.yml` file instead), you'll want to add the queue `releases` to the top of the list.

## Schema.org structured data as JSON-LD

### What's Changing?

[Schema.org](https://schema.org) structured data was previously represented in microdata format. This format enforced metadata attributes to be placed on relevant elements in views across the Storefront. The problem with this approach is that a developer will frequently edit markup to satisfy project requirements and can unwittingly cause the metadata to become invalid.

**Beginning in Workarea v3.5 we remove microdata from all Storefront views, favoring the recommended JSON-LD format** for which the following helpers have been written:

* `Workarea::SchemaOrgHelper`
* `Workarea::Storefront::SchemaOrgHelper`

### What Do You Need to Do?

**Switching from the microdata format to the JSON-LD format is not mandatory** as valid microdata is still an accepted format. It is, however, highly recommended that apps are upgraded to use the new format, as views that have not been overridden in the app will automatically begin using the new format. Offering a mixture of both microdata and JSON-LD is not recommended.

## Removal of Storefront product price partial

### What's Changing?

The conversion of the Schema.org structured data also rendered the `workarea/storefront/product/price` partial obsolete, as its primary purpose was to assist with the rendering of Schema.org Product Offer schema at the price level.

The contents of this partial are now directly rendered within the `workarea/storefront/product/pricing` partial itself.

* [Pull request](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3926/overview)
* [JIRA ticket](https://jira.tools.weblinc.com/browse/ECOMMERCE-6743)

### What Do You Need to Do?

These changes will be caught and displayed via the diffing functionality of the _Workarea Upgrade_ tool.

## Updates to Headless Chrome Configuration

### What's Changing?

To accommodate future on-demand changes related to Chrome's auto-updating, we're renaming a Workarea configuration and adding a new one. The names now more accurately reflect how they're used.

### What Do You Need to Do?

If you're using `Workarea.config.headless_chrome_options`, you'll need to rename that to `Workarea.config.headless_chrome_args`. Some applications set up with Docker for local development will be affected by this.

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

We looked to offer more robust features around digital products in v3.5. As a result, `Fulfillment::Sku` was introduced as a way to define how each SKU is fulfilled. Each Fulfillment SKU has a policy, much like Inventory SKUs, that define what should be done upon the completion of checkout for an item of a particular SKU. By default there are 3 policies: shipping, digital, and download. `Shipping` does nothing when the order is placed, but indicates throughout checkout that shipping will be required for the item. This will be the default and most common policy. `Digital` handles what is currently `Catalog::Product#digital?`, in that it does nothing automatically when the order is placed but represents a non-shipping item. The `Download` policy provides enhanced functionality for digital items. Admin can associate a file to a Fulfillment SKU with a download policy, which will automatically generate a unique token for purchase that gives the user access to a download link in the summary of their order after completion and any time after that from their order history. Each policy defines automated behavior when the order is placed for that SKU. This allows flexibility to have some automation but still require human intervention to fully fulfill the item.

As a part of this process, the `digital?` flag on products was no longer necessary. The field is still defined, and will be removed completely in future versions. Instead, this concern was shifted fully to `Fullfillment::Sku`.

### What Do You Need To Do?

If you're using the `Catalog::Product#digital?` flag, you'll want to write a custom fulfillment policy to achieve your functionality. [See the fulfillment SKUs article on developer.workarea.com](https://developer.workarea.com/articles/fulfillment-skus.html)

## Move Storefront Search Autocomplete Functionality to Plugin

### What's Changing?

We've removed the default Search Autocomplete functionality from the Storefront into a plugin to be able to give applications more flexibility.

### What Do You Need To Do?

To keep this functionality present in your application you'll need to install the `workarea-classic_search_autocomplete` plugin.

## jQuery UI Autocomplete Widget Removed

### What's Changing?

Due to the removal of Search Autocomplete, the jQuery UI Autocomplete widget is also no longer necessary from a base platform perspective.

### What Do You Need To Do?

If another JavaScript module was making use of the jQuery UI Autocomplete widget keep the following referenced in your JavaScript application manifest:

* `jquery-ui/widgets/autocomplete`

and the following referenced in your Stylesheet application manifest:

* `@import 'jquery_ui/storefront/ui_autocomplete';`
* `@import 'jquery_ui/storefront/ui_menu';`

## Segments Plugin Deprecated

### What's Changing?

Segments functionality has been moved into the base Workarea platform. We believe this is important for all retailers. Consequently, the `workarea-segmentation` plugin is deprecated, and will not be supported going forward. The new segmenting engine is far more powerful than the plugin was and will allow much more flexibility. In the future, we will be expanding functionality on this new segmentation engine.

### What Do You Need To Do?

You'll need to remove `workarea-segmentation` from your Gemfile. We've added code in the migration script (`bin/rails workarea:migrate:v3_5`) to help with the transition. The script will do its best to migrate segments to the new v3.5 MongoDB document structure. However, not all conditions from the plugin are supported in base at this point, so some segments may not migrate. The script will output this. Please reach out to the Workarea team for assistance if this creates a problem.

## Configuration management added to Admin UI

### What's Changing?

There is now an Admin page for configuration values. This page allows admin users to edit some of the runtime configuration values that were previously static configuration defined within the code.

### What Do You Need To Do?

Review the Admin configuration page. If your application has defined any static configuration values that conflict with fields that are now administrable, those fields will have a red "!" icon next to them with a message indicating they are being overridden by static configuration. If you want to allow those fields to be changed by admin users, you should remove those values from your configuration file, and instead redefine the default value of the admin configuration field ([See the article on developer.workarea.com](https://developer.workarea.com/articles/configuration-fields.html)). Otherwise, you can leave them alone and they will continue to function as before.

## Encrypted fields are now available

### What's Changing?

This is a purely additive feature that was included to support encrypted configuration fields within the Admin. Any model field can now define the `encrypted` option to automatically be encrypted for writing to the database, and decrypted upon reading from the database. This uses Rails's built-in encryption used for credentials via a master key.

```ruby
class SomeModel
  include Mongoid::Document
  include Mongoid::Encrypted

  field :secret_text, type: :string, encrypted: true
end
```

### What Do You Need To Do?

If your application, or any plugin you application is using defines an encrypted field, you will need to make sure your project has a master key configured and present to prevent errors when accessing models with an encrypted field. [See the Rails guide for more information on using a master key](https://edgeguides.rubyonrails.org/security.html?utm_source=twitterfeed&utm_medium=twitter#custom-credentials).

## S3 isn't the default asset store anymore

### What's Changing?

To play nicer with non Commerce Cloud hosting solutions, we removed the default behavior of setting the Dragonfly asset store
to S3 when in an environment that isn't `test` or `development`.

### What Do You Need To Do?

To retain the old behavior (which you'll want if you're on the Workarea Commerce Cloud) drop this into an initializer:

```ruby
Workarea.config.asset_store = (Rails.env.test? || Rails.env.development?) ? :file_system : :s3
```

## Switch to Use the Rails Redis Cache Store

### What's Changing?

Rails added an official out-of-the-box Redis cache store, so we don't need to depend on the `redis-rails` gem.

### What Do You Need To Do?

Update your app's Rails cache config in the various `config/environments` from `config.cache_store = :redis_store, Workarea::Configuration::Redis.cache.to_url` to `config.cache_store = :redis_cache_store, { url: Workarea::Configuration::Redis.cache.to_url }`.
