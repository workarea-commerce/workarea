---
title: Workarea 3.0.5
excerpt: #2506
---

# Workarea 3.0.5

## Adds VCR Configuration

[#2506](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2506/overview)

Workarea Testing 3.0.5 provides a default configuration for the [vcr](https://github.com/vcr/vcr) library, including a custom cassette persister, `Workarea::Testing::CassettePersister`.

This configuration persists cassettes to _test/vcr\_cassettes/_ within the current application or engine. When fetching a cassette, vcr will search within the current application and each installed Workarea engine for the given cassette.

If your application or engine has already configured vcr, remove or update your configuration to ensure compatibility with the defaults provided by Workarea Testing. Ensure all cassettes are persisted to _test/vcr\_cassettes/_.

## Fixes Display of Image Group Content Blocks

[#2501](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2501/overview)

Workarea 3.0.5 modifies the Storefront partial for image group content blocks, _workarea/storefront/content\_blocks/\_image\_group.html.haml_, to output only as many grid cells as there are images in the image group. Before 3.0.5, additional (empty) grid cells are output when images are cleared.

Additionally, the default presentation of image group content blocks is simplified, using a centered grid starting at the _medium_ screen width.

![image group content block in Storefront](images/image-group-content-block-in-storefront.png)

The pull request also adds the `Workarea::Content::Asset#image_placeholder?` method and the _workarea/storefront/style\_guides/components/\_image\_group\_content\_block.html.haml_ style guide partial in the Storefront.

If your application is overriding the image group content block partial, you should update your copy to avoid empty grid cells in the Storefront.

## Replaces Heading Elements within Content Blocks

[#2498](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2498/overview)

Within all Storefront content block partials, Workarea 3.0.5 replaces `h2` elements with `span` elements that extend the `%heading--2` styles. The intention is to remove these elements from the document outline (because their placement is unpredictable) without affecting their appearance. The following list includes the affected selectors and the corresponding view and stylesheet for each.

- `.category-summary-content-block__heading`
  - workarea/storefront/content\_blocks/\_category\_summary.html.haml
  - workarea/storefront/components/\_category\_summary\_content\_block.scss
- `.product-list-content-block__heading`
  - workarea/storefront/content\_blocks/\_product\_list.html.haml
  - workarea/storefront/components/\_product\_list\_content\_block.scss
- `.personalized-recommendations-content-block__heading`
  - workarea/storefront/recommendations/show.html.haml
  - workarea/storefront/components/\_personalized\_recommendations\_content\_block.scss

If your application is overriding any of the above views or stylesheets, consider updating your copies for consistency.

## Internationalizes Email Templates

[#2502](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2502/overview)

Prior to 3.0.5, a few email templates contain untranslated text strings. Workarea 3.0.5 internationalizes the Admin email layout and one mailer in Storefront. The following views are affected.

- layouts/workarea/admin/email.html.haml
- layouts/workarea/admin/email.text.erb
- workarea/storefront/order\_mailer/\_summary.html.haml

And the following translations are added to the _en_ locale.

- workarea.admin.layout.mailer.title
- workarea.admin.layout.mailer.homepage\_link

Additionally, the following mailers are modified to remove unnecessary `br` elements.

- workarea/storefront/fulfillment\_mailer/canceled.html.haml
- workarea/storefront/fulfillment\_mailer/shipped.html.haml
- workarea/storefront/order\_mailer/reminder.html.haml

If your application is overriding any of the above mailer views, you may want to apply the changes to your copies of the files.

## Fixes Pagination Test Failures

[f0448bdb3ac](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/f0448bdb3acd372ace1fe9d347d6a16d0a7b2a0e)

Workarea 3.0.5 modifies the _workarea/storefront/modules/pagination.js_ JavaScript module in the Storefront to fix a timing issue causing automated test failures.

The public API of the `WORKAREA.pagination` module is unaffected, however, if your application is overriding this module you'll need to apply the changes within your copy of the file to avoid intermittent test failures.

## Fixes Async Replacement of Product Details

[c9696eaccb2](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c9696eaccb2ab3d5481c90393b3bd1257182a6eb)

The `WORKAREA.productDetailsSkuSelects` module is responsible for the asynchronous replacement of product details when the sku select is changed, however, the functionality is broken prior to 3.0.5. Workarea 3.0.5 modifies _workarea/storefront/modules/product\_details\_sku\_selects.js_ to fix a DOM query within the implementation.

The change does not affect the API of `WORKAREA.productDetailsSkuSelects`, but if your application is overriding this module, you'll need to apply the fix manually.

## Fixes File Extension of Taxonomy Content Block Partials

[#2498](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2498/overview)

Workarea 3.0.5 renames the following files to change the file extension from _.haml_ to _.html.haml_. The name change should cause no functional change—it simply corrects the file extension to avoid confusion when overriding.

- workarea/storefront/content\_blocks/\_taxonomy.haml
- workarea/storefront/content\_blocks/\_three\_column\_taxonomy.haml
- workarea/storefront/content\_blocks/\_two\_column\_taxonomy.haml

The pull request also removes the vestigal and unused `taxonomy-content-block__container--image` class value from the above files.

These changes should have no effect on your application, but if you are overriding any of these partials, review the changes to be sure.

## Fixes Position of Tooltips on Admin Imports Screens

[#2504](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2504/overview)

Workarea 3.0.5 adds data attributes to the following Admin views to position tooltips correctly.

- workarea/admin/import\_catalogs/new.html.haml
- workarea/admin/tax\_imports/new.html.haml

If your application is overriding these views, you should apply these changes to your copies of the files.

## Skips Activity Headings if No Entries

[c0863d12c83](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c0863d12c83d6bb2ee02549a711893177fe3ff72)

Workarea 3.0.5 modifies _workarea/admin/activities/show.html.haml_ to not output heading elements within activity for days that have no entires.

If your application is overriding this view, you may want to apply this change in your copy of the file.

## Displays Multiple Tenders in Order Admin

[#2497](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2497/overview)

Workarea 3.0.5 modifies the _workarea/admin/orders/\_cards.html.haml_ partial in the Admin to display up to 3 payment tenders, rather than the first tender only. The payment for an order may contain multiple tenders, such as when a gift card and credit card are used as payment on the same order. That scenario is shown in the example below (requires the [Workarea Gift Cards](https://stash.tools.weblinc.com/projects/WL/repos/workarea-gift-cards/browse) plugin).

![orders show with multiple tenders](images/order-show-with-multiple-tenders.png)

If your application is overriding this partial, update your copy to allow for the display of multiple tenders.

## Adds Utility Nav Append Point to Storefront Application Layout

[#2490](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2490/overview)

Workarea 3.0.5 adds the _storefront.utility\_nav_ append point to the Storefront application layout, _layouts/workarea/storefront/application.html.haml_.

If your application is overriding this layout, update your copy so that plugins may append to the new append point.

## Fixes Status Facet for Releasables

[#2499](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2499/overview)

Admin search models for [releasables](releasable.html) include a _status_ facet. Prior to 3.0.5, the `status` method on these models is either missing or always returns `'active'`. Workarea 3.0.5 moves this method to `Workarea::Search::Admin::Releasable` and returns either `'active'` or `'inactive'`, depending on the status of the underlying model, as shown below.

```
# workarea-core/app/models/workarea/search/admin/releasable.rb

module Workarea
  module Search
    class Admin
      module Releasable
        # ...

        def status
          if model.active?
            'active'
          else
            'inactive'
          end
        end

        # ...
      end
    end
  end
end
```

The following search models are affected.

- `Workarea::Search::Admin::CatalogCategory`
- `Workarea::Search::Admin::Content`
- `Workarea::Search::Admin::ContentPage`
- `Workarea::Search::Admin::PricingDiscount`
- `Workarea::Search::Admin::PricingSku`

In the unlikely case your application is decorating the `status` method on any of the above classes, update your decorators accordingly.

## Removes Items from Order if Variants Are Inactive

[#2500](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2500/overview)

Before each `Workarea::Storefront::CartsController` action, `Workarea::CartCleaner#clean` mutates the current order, removing items if the corresponding products are unpurchasable. Workarea 3.0.5 also removes items if the corresponding variants are inactive. The updated `clean` implementation is shown below.

```
# workarea-core/app/services/workarea/cart_cleaner.rb

module Workarea
  class CartCleaner
    # ...

    def clean
      items_to_remove = []

      cart.items.each do |item|
        product = products.detect { |p| p.id == item.product_id }
        variant = product && product.variants.detect { |v| v.sku == item.sku }
        # ...

        unless product.purchasable? && variant.try(:active?) #
```

No action is required when upgrading, but be aware of this change in application behavior.

## Adds Missing Style Guide Partials for Content Blocks

[#2498](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2498/overview)

Workarea 3.0.5 adds the following style guide partials in the Storefront, which are missing prior to this release.

- workarea/storefront/style\_guides/components/\_divider\_content\_block.html.haml
- workarea/storefront/style\_guides/components/\_html\_content\_block.html.haml
- workarea/storefront/style\_guides/components/\_image\_and\_text\_content\_block.html.haml
- workarea/storefront/style\_guides/components/\_personalized\_recommendations\_content\_block.html.haml
- workarea/storefront/style\_guides/components/\_product\_list\_content\_block.html.haml
- workarea/storefront/style\_guides/components/\_social\_networks\_content\_block.html.haml
- workarea/storefront/style\_guides/components/\_taxonomy\_content\_block.html.haml
- workarea/storefront/style\_guides/components/\_text\_content\_block.html.haml
- workarea/storefront/style\_guides/components/\_video\_and\_text\_content\_block.html.haml
- workarea/storefront/style\_guides/components/\_video\_content\_block.html.haml

Additionally, the `workarea/storefront/content_blocks/_navigation.haml` partial is removed because it is not used.


