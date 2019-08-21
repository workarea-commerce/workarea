---
title: Workarea 3.0.13
excerpt: #2746
---

# Workarea 3.0.13

## Removes Deleted Products from Recommendations

[#2746](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2746/overview)

Workarea 3.0.13 adds the `Workarea::CleanProductRecommendations` worker. The worker enqueues on `Catalog::Product => :destroy` and removes the deleted product from the product predictor.

The PR also adds the following tests.

- `CleanProductRecommendationsTest#test_perform`
- `Workarea::Recommendation::ProductBasedTest#test_not_including_deleted_products`

## Fixes Re-Indexing of Products after Category Change

[#2748](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2748/overview)

Workarea 3.0.13 modifies the Core worker `Workarea::IndexCategoryChanges` to fix the logic used to determine which products require re-indexing. This fixes featured product order in the Storefront when only the order of featured products is changed in the Admin. The PR changes `perform` and adds `require_index_ids`.

The PR also adds the Core worker test `Workarea::IndexCategoryChangesTest#test_require_index_ids`.

## Adds Expiration for Render Content Blocks Cache

[#2738](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2738/overview)

Workarea 3.0.13 modifies the Storefront helper `Workarea::Storefront::ContentHelper`, adding an expiration to the `render_content_blocks` cache, which was unintentionally omitted in the previous implementation.

The change also adds the Core config `Workarea.config.cache_expirations.content_blocks` to configure the length of the cache.

## Improves Quality of Search Reporting in Admin

[#2757](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2757/overview)

Workarea 3.0.13 applies the following improvements/fixes to search reporting in the Admin.

- Excludes queries of fewer than 3 characters
- Uses only the top 3% of searches for top searches (the long tail)
- Ignores searches with abandonment greater than 100%
- Further attempts to prevent searches with abandonment greater than 100%

The changes are as follows.

- Modifies Admin locale _admin/config/locales/en.yml_
  - Modifies _workarea.admin.dashboards.search\_abandonment.searches\_to\_improve\_info\_tooltip\_html_
- Modifies Core model `Workarea::Analytics::LastFourWeeksSearch`
  - Adds `scope :with_terms`
  - Modifies `self.to_improve`
- Modifies Core model `Workarea::Analytics::Search`
  - Modifies `self.save_search`
  - Modifies `self.save_abandonment`
- Modifies Core model `Workarea::QueryString`
  - Adds `short?`
- Modifies Core model test case `Workarea::Analytics::SearchTest`
  - Modifies `test_save_search`
  - Modifies `test_save_abandonment`
- Modifies Storefront JavaScript module _workarea/storefront/modules/workarea\_analytics.js_
  - Modifies `searchResultsView()`
- Modifies Storefront controller `Workarea::Storefront::AnalyticsController`
  - Modifies `product_view`
  - Modifies `search`
  - Modifies `search_abandonment`
  - Modifies `filters`
  - Adds `robot?`
- Modifies Storefront integration test case `Workarea::Storefront::AnalyticsIntegrationTest`
  - Adds `test_blocking_bots`

## Changes Storefront Logo to PNG for Compatibility with Open Graph

[#2682](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2682/overview)

Workarea 3.0.13 replaces the Storefront image file _workarea/storefront/logo.svg_ with _workarea/storefront/logo.png_ to provide a valid image file for use with Open Graph. The PR also modifies _core/config/initializers/02\_assets.rb_ to include the new file as a pre-compiled asset. Furthermore, within the Storefront stylesheet _workarea/storefront/components/\_page\_header.scss_, the value of `$page-header-logo-height` changes to reflect a change in logo height.

The following Storefront views are modified to change the path to the image file.

- _layouts/workarea/storefront/application.html.haml_
- _layouts/workarea/storefront/checkout.html.haml_
- _workarea/storefront/categories/show.html.haml_
- _workarea/storefront/pages/home\_page.html.haml_
- _workarea/storefront/pages/show.html.haml_
- _workarea/storefront/searches/show.html.haml_

## Fixes Taxonomy Content Block When Starting Taxon is Deleted

[#2753](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2753/overview)

Workarea 3.0.13 changes the Storefront view model module `Workarea::Storefront::TaxonLookup`, modifying `starting_taxon` and `taxons` to avoid raising an exception when the starting taxon of a taxonomy content block cannot be found (was deleted).

The change adds the Storefront test case `Workarea::Storefront::ContentBlocks::TaxonomyViewModelTest` with tests `test_starting_taxon` and `test_taxons` to confirm the fix.

The PR also modifies the Admin partial _workarea/admin/navigation\_taxons/\_select.html.haml_ to output a "not found" message rather than a taxon selector UI when the selected taxon is not found. A translation for this message is added as _workarea.admin.navigation\_taxons.select.none\_selected_ to the Admin locale file _admin/config/locales/en.yml_.

## Changes Behavior of Menu Deletion in Admin

[#2751](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2751/overview)

Workarea 3.0.13 modifies the `destroy` action on the Admin controller `Workarea::Admin::NavigationMenusController` to de-activate, rather than destroy, the menu when a current release is present. This change fixes the unexpected behavior of deleting the menu from the live site.

The change also adds the test `Workarea::Admin::MenusIntegrationTest#test_deactivates_menu_when_deleting_on_a_release`.

## Fixes Display of Search Customizations Activity

[#2737](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2737/overview)

Workarea 3.0.13 modifies the Admin partial _workarea/admin/activities/\_search\_customization\_destroy.html.haml_ to use the correct translation and avoid raising an exception in some cases.

## Ensures Invalid Shipping Options When No Shipping Service

[#2739](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2739/overview)

Workarea 3.0.13 changes Core model method `Workarea::Checkout::Shipping::Options#valid?` to return `false` when the current checkout's shipping service is blank. This change avoids an undesirable state exposed when using the Storefront REST API.

The PR also adds the Core model test case `Workarea::Checkout::ShippingOptionsTest`, which was converted from RSpec and includes the following instance methods.

- `order`
- `shipping`
- `shipping_options`
- `shipping_service` (setup)
- `setup_order` (setup)
- `test_available`
- `test_valid`

## Ignores 404s When Deleting Documents from Elasticsearch

[#2732](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2732/overview)

Workarea 3.0.13 modifies the Core library method `Workarea::Elasticsearch::Index#delete` to not raise an exception when the document to be deleted is not found.

## Fixes Non-Human-Readable Content Block Names in Admin

[#2733](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2733/overview), [#2741](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2741/overview)

Workarea 3.0.13 modifies Core model method `Workarea::Content::BlockName#to_s` to avoid displaying non-human-readable content block names in the Admin.

The change also adds the Core model test `Workarea::Content::BlockNameTest#test_name_is_human_readable`.

## Improves Product Primary Image Alt Text

[#2729](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2729/overview)

Workarea 3.0.13 modifies the Storefront partial _workarea/storefront/products/templates/\_generic.html.haml_ to improve the primary image alt text. The change also internationalizes the value, which was a static string. The PR modifies _storefront/config/locales/en.yml_, adding the translation _workarea.storefront.products.image\_alt\_attribute_.

## Improves VCR Error Messages

[#2742](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2742/overview)

Workarea 3.0.13 modifies the Testing library module `Workarea::Testing::CassettePersister`, implementing `absolute_path_to_file`, which allows VCR to provide improved error messages when a found cassette does not match the URL being testing. The change also modifies `[]` on the same module.


