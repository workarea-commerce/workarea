---
title: Workarea 3.0.9
excerpt: #2637, 00e83b32fc1
---

# Workarea 3.0.9

## Internationalizes Currency Symbol in Admin

[#2637](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2637/overview), [00e83b32fc1](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/00e83b32fc1edeea777e98542dcfa4745e4f01d9)

Workarea 3.0.9 internationalizes the currency symbol in the Admin by replacing instances of the static string `$` with calls to `Money::Currency#symbol` ([docs](http://www.rubydoc.info/gems/money/6.8.4/Money/Currency#symbol-instance_method)) and `MoneyRails::ActionViewExtension#currency_symbol` ([docs](http://www.rubydoc.info/gems/money-rails/1.8.0/MoneyRails/ActionViewExtension#currency_symbol-instance_method)) from the [Money](https://rubygems.org/gems/money/versions/6.8.4) ([docs](http://www.rubydoc.info/gems/money/6.8.4)) and [MoneyRails](https://rubygems.org/gems/money-rails/versions/1.8.0) ([docs](http://www.rubydoc.info/gems/money-rails/1.8.0)) libraries, respectively.

The following Admin views are affected.

- _workarea/admin/bulk\_action\_product\_edits/edit.html.haml_
- _workarea/admin/create\_catalog\_products/variants.html.haml_
- _workarea/admin/facets/\_price\_inputs.html.haml_
- _workarea/admin/orders/index.html.haml_
- _workarea/admin/prices/edit.html.haml_
- _workarea/admin/prices/new.html.haml_
- _workarea/admin/pricing\_discounts/conditions/\_order\_total.html.haml_
- _workarea/admin/pricing\_discounts/properties/\_quantity\_fixed\_price.html.haml_
- _workarea/admin/pricing\_discounts/properties/\_shipping.html.haml_
- _workarea/admin/pricing\_skus/edit.html.haml_
- _workarea/admin/pricing\_skus/new.html.haml_
- _workarea/admin/product\_rules/fields/\_price.html.haml_
- _workarea/admin/users/edit.html.haml_

And the following Admin tests are affected.

- `Workarea::Admin::ReleasesHelperTest#test_change_display_value`
- `Workarea::Admin::JumpToIntegrationTest#test_finding_prices`
- `Workarea::Admin::OrdersSystemTest#test_attributes`
- `Workarea::Admin::OrdersSystemTest#test_shipping`
- `Workarea::Admin::OrdersSystemTest#test_payment`
- `Workarea::Admin::PaymentTransactionsSystemTest#test_viewing_transactions`
- `Workarea::Admin::PricingSkusSystemTest#test_prices`
- `Workarea::Admin::TaxCategoriesSystemTest#test_viewing_existing_tax_rates`
- `Workarea::Admin::DiscountRulesViewModelTest#test_amount`

Furthermore, Workarea 3.0.9 extends Rails' `number_to_currency` helper method to ensure the correct currency symbol (from `Money::Currency#symbol`) is used in the output. Rails uses locale to determine the currency symbol, but Workarea uses the Money library to manage currency.

The change adds `workarea-core/lib/workarea/ext/freedom_patches/action_view_number_helper.rb`, which extends `ActionView::Helpers::NumberHelper#number_to_currency`.

## Internationalizes Category & Search System Tests in Storefront

[#2617](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2617/overview)

Workarea 3.0.9 modifies the following Storefront tests to internationalize static text strings within each.

- 

`Workarea::Storefront::CategoriesSystemTest`

  - `test_sorting_products`
  - `test_filtering_products_and_sorting`
- 

`Workarea::Storefront::SearchSystemTest`

  - `test_sorting_results`
  - `test_filter_and_sorting_results`
  - `test_search_content`

## Fixes UI Persistence Issues in Product Bulk Edit Flow

[#2645](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2645/overview)

Workarea 3.0.9 fixes the UI for the product bulk edit flow in the Admin, where some changes were incorrectly persisting and not persisting across the steps of the flow.

The change modifies the Core model `Workarea::BulkAction`, adding `reset_to_default!`, and the Admin view model `Workarea::Admin::BulkActionProductEditViewModel`, adding `pricing_prices`.

The change also modifies the Admin controller method `Workarea::Admin::BulkActionProductEditsController#update` and the Admin view _workarea/admin/bulk\_action\_product\_edits/edit.html.haml_.

Finally, the change adds the Core model test `Workarea::BulkActionTest#test_reset_to_default` and modifies the Admin system test `Workarea::Admin::BulkActionsSystemTest#test_bulk_editing`.

## Restores Whitespace Under Admin Browsing Controls

[#2642](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2642/overview)

Workarea 3.0.9 restores negative space removed from the _browsing controls_ component in Workarea 3.0.7 after further testing revealed the need for the space in some views. The change modifies `.browsing-controls {}` within the Admin stylesheet _workarea/admin/components/\_browsing\_controls.scss_.

## Prevents Linking to Nonexistent Products in Admin Auxiliary Nav

[#2633](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2633/overview)

Workarea 3.0.9 prevents linking to nonexistent products from the Admin auxiliary navigation for inventory skus and pricing skus. The change affects the following Admin partials.

- _workarea/admin/inventory\_skus/\_aux\_navigation.html.haml_
- _workarea/admin/pricing\_skus/\_aux\_navigation.html.haml_

## Hides Inactive Blocks on Admin Content Cards

[#2647](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2647/overview)

Workarea 3.0.9 modifies the Admin content card partial, _workarea/admin/content/\_card.html.haml_, filtering the enumerated blocks to only those that are active.

## Prevents Sorting Taxons in Taxonomy Content Block Admin

[#2644](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2644/overview)

Workarea 3.0.9 prevents sorting taxons in the taxonomy content block Admin, which was previously possible since code for the feature is shared with the menu editor (where taxon sorting is allowed). The change modifies the Admin JavaScript module _workarea/admin/modules/menu\_editor\_menu\_list\_sortables.js_, causing `WORKAREA.menuEditorMenuListSortables.init()` to return early if the elements to be manipulated are within the content editor UI.

## Adds Delete Confirmation to Prices Index in Admin

[#2630](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2630/overview)

Workarea 3.0.9 modifies the _workarea/admin/prices/index.html.haml_ Admin view, adding a delete confirmation prompt to the delete button for each price.

## Fixes Paths to SVGs in Admin Import Views

[#2623](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2623/overview), [#2656](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2656/overview)

Workarea 3.0.9 fixes paths to SVG files within the following Admin views.

- _workarea/admin/import\_catalogs/index.html.haml_
- _workarea/admin/import\_catalogs/show.html.haml_
- _workarea/admin/tax\_imports/index.html.haml_
- _workarea/admin/tax\_imports/show.html.haml_

## Fixes Password Reset Exception in Storefront when User is Not Found

[#2624](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2624/overview)

Workarea 3.0.9 modifies `Workarea::Storefront::Users::PasswordsController#create` to prevent raising an exception when no user is found with the given email. This change provides increased privacy for all users and an improved user experience for users who enter their email incorrectly while requesting a password reset.

The change also modifies the `workarea.storefront.flash_messages.password_reset_email_sent` translation in the Storefront's _en.yml_ locale file. Furthermore, the PR modifies the `Workarea::Storefront::PasswordsSystemTest#test_customer_resetting_a_password` system test in the Storefront, adding an assertion to test a bogus email.

## Fixes Open Graph Metadata in Storefront

[#2662](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2662/overview), [#2664](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2664/overview)

Workarea 3.0.9 fixes the values for the _og:image_ and _og:url_ [Open Graph](http://ogp.me/) properties in the Storefront, ensuring each value is an absolute URL to an existing resource.

The following Storefront views are affected.

- _workarea/storefront/categories/show.html.haml_
- _workarea/storefront/pages/home\_page.html.haml_
- _workarea/storefront/pages/show.html.haml_
- _workarea/storefront/products/show.html.haml_
- _workarea/storefront/searches/show.html.haml_

## Fixes Shipping Rate Parent Association

[#2661](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2661/overview)

Workarea 3.0.9 modifies the Core model `Workarea::Shipping::Rate`, changing the `embedded_in :method` association to `embedded_in :service`. The change correctly reflects the parent model, `Workarea::Shipping::Service`, renamed from `Workarea::Shipping::Method` in Workarea 3.0.0.

## Fixes Content Block Data not Persisting after Typecasting

[#2668](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2668/overview)

Workarea 3.0.9 changes some implementation details within `Workarea::Content::Block#typecast` and `Workarea::Content::Blocktype#typecast!` to ensure content block data persists after typecasting.

The change also modifies the following test, adding assertions to confirm the fix: `Workarea::Content::BlockTest#test_valid_typecasts_the_values_in_the_data_block`.

## Fixes Undefined Method Errors in Sidekiq

[#2621](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2621/overview)

Workarea 3.0.9 fixes the implementation of `Sidekiq::CallbacksWorker.enqueue_on` to resolve _undefined method_ errors in Sidekiq.

## Fixes Redis Config URL

[d8e0745bdf9](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/d8e0745bdf99b3e9d8d180108f7f4ef964937ef6), [d4fa747bc74](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/d4fa747bc7465eaa92f6618d6a0aa307d24cd767)

Workarea 3.0.9 modifies `Workarea::Configuration::Redis#to_url` to create consistent URL strings when `Workarea::Configuration::Redis#port` and `Workarea::Configuration::Redis#db` are `nil`.

## Deletes Redis Data when Running Seeds

[#2631](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2631/overview)

Workarea 3.0.9 modifies the Core library module `Workarea::Seeds`, adding `Workarea::Seeds.delete_redis_data` and modifying `Workarea::Seeds.reset` to call `delete_redis_data`. The change causes Redis to be flushed when running seeds (after deleting data from Elasticsearch and MongoDB).

## Fixes Changelog Rake Task in Plugin Template

[#2643](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2643/overview)

Workarea 3.0.9 modifies the plugin template script, _workarea/docs/guides/source/plugin\_template.rb_, in order to fix the `:changelog` Rake task created within the _Rakefile_ of new plugins.

If you created a plugin using an earlier version of the plugin template, you should update the plugin's _Rakefile_ to fix the `:changelog` task.

## Adds Teaspoon Configuration to Plugin Template

[#2655](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2655/overview)

Workarea 3.0.9 modifies the plugin template script, _workarea/docs/guides/source/plugin\_template.rb_, adding configuration for [Teaspoon](https://github.com/jejacks0n/teaspoon) and two Rake tasks for use with Teaspoon: `:teaspoon` and `:teaspoon_server`.

## Excludes Docs Directory from RDoc

[#2620](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2620/overview)

Workarea 3.0.9 modifies _workarea.gemspec_ to exclude the _docs_ directory from RDoc generation. The change prevents a `RDoc::Parser::Ruby` failure when RDoc runs during gem installation.


