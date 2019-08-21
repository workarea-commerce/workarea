---
title: Workarea 3.0.11
excerpt: #2708
---

# Workarea 3.0.11

## Replaces minitest-reporters with minitest-junit

[#2708](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2708/overview)

Workarea 3.0.11 replaces minitest-reporters with [minitest-junit](https://rubygems.org/gems/minitest-junit/versions/0.2.0) for CI test reporting. Changes in Rails 5.0.5 caused usability problems in minitest-reporters that likely can't be fixed.

In addition to updating the Core gemspec, the change removes all setup for minitest-reporters from _workarea-testing/lib/workarea/test\_help.rb_ and adds a Workarea Minitest plugin at _workarea-core/lib/minitest/workarea\_plugin.rb_ to apply the necessary setup for minitest-junit.

## Moves Additional Test Cases into Their Own Files

[165dd39211a](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/165dd39211a8b084965055628058100db14f8f0d)

Workarea 3.0.11 modifies and adds several test case files to ensure each file contains only one class definition which matches the file name. Developers [reported problems](https://discourse.weblinc.com/t/multiple-classes-in-discounting-system-test/843) decorating test cases when the class name and file name don't match. This change does not change the Ruby API in any way, only where on disk the classes are defined.

The following files are modified to remove additional class definitions.

- _workarea-core/test/models/workarea/content/asset\_test.rb_
- _workarea-core/test/models/workarea/address\_test.rb_
- _workarea-storefront/test/system/workarea/storefront/discounting\_system\_test.rb_

And the following files are added.

- _workarea-core/test/models/workarea/content/asset\_validation\_test.rb_
- _workarea-core/test/models/workarea/address\_equality\_test.rb_
- _workarea-core/test/models/workarea/address\_validation\_test.rb_
- _workarea-storefront/test/system/workarea/storefront/discounting\_multiple\_system\_test.rb_

## Fixes Category Rule Changes Requiring Re-Indexing

[8e9645e6daf](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/8e9645e6daf4cb8ae64ac6fa5236da820178bcb0)

Applications reported category rule changes not taking effect without re-indexing in some cases. Workarea 3.0.11 applies the following changes to fix this issue.

**To receive the full benefit of this change, you must re-index all Storefront indexes, although this is not required and the application will continue to work.**

- Modifies Core search model (mixin) `Workarea::Search::Storefront::Product::Categories`
  - Modifies `category_id`
- Modifies Core search model test case `Workarea::Search::Storefront::Product::CategoriesTest`
  - Removes `test_includes_all_category_ids_the_product_has`
  - Adds `test_includes_featured_category_ids_the_product_has`
- Modifies Core search query `Workarea::Search::ProductRules`
  - Modifies `initialize`
  - Adds `ignore_category_ids`
  - Modifies `to_a`
  - Modifies `category_clauses_for`
- Modifies Core search query test case `Workarea::Search::ProductRulesTest`
  - Modifies `test_category_rules`
  - Adds `test_category_reference_loop`
- Modifies Core search query test case `Workarea::Search::CategoryBrowseTest`
  - Adds `test_matching_featured_in_category_rule`
  - Adds `test_matching_rules_and_featured_in_category_rule`

## Adds Additional Search Mappings to Prevent Indexing Errors
[5321cdbf19a](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/5321cdbf19a671d0242cc3f1b9c034ddc871a44a)

Workarea 3.0.11 adds the `'facets.category_id'` and `'facets.on_sale'` properties to the `:storefront` Elasticsearch mapping in `workarea-core/lib/workarea/configuration.rb`. This change reduces the chances of errors during indexing.

```
# workarea-core/lib/workarea/configuration.rb

config.elasticsearch_mappings.storefront = {
  # ...
  storefront: {
    # ...
    properties: {
      id: { type: 'keyword' },
      type: { type: 'keyword' },
      slug: { type: 'keyword' },
      suggestion_content: { type: 'string', analyzer: 'text_analyzer' },

      # This would be covered by the facets dynamic mapping but to reduce
      # the likelihood of no-field-mapping errors, including
      # out-of-the-box mappings here.
      'facets.category_id' => { type: 'keyword' },
      'facets.on_sale' => { type: 'keyword' }
    }
  }
}
```

## Fixes Fulfillment Cancellation Issues

[#2712](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2712/overview)

Workarea 3.0.11 modifies the fulfillment model to prevent adding cancel events to fulfillment items when the canceled quantity is 0. The change also improves the fulfillment mailer implementation.

The PR makes the following changes.

- Modifies Core model `Workarea::Fulfillment`
  - Modifies `cancel_items`
- Modifies Core model test case `Workarea::FulfillmentTest`
  - Removes `test_cancel_items_adds_the_shipped_events_to_the_items`
  - Adds `test_cancel_items_adds_the_canceled_events_to_the_items`
- Modifies Storefront mailer preview `Workarea::Storefront::FulfillmentMailerPreview`
  - Modifies `canceled`
- Modifies Storefront mailer (Haml) _workarea/storefront/fulfillment\_mailer/canceled.html.haml_
- Modifies Storefront mailer (text) _workarea/storefront/fulfillment\_mailer/canceled.text.erb_

## Fixes Rendering of Style Guide Partials

[#2639](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2639/overview), [cb15fc2f585](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/cb15fc2f585340c6c2ad805ff7d80a8674beadd5)

Workarea 3.0.11 fixes the Core style guides helper to prevent style guide partials rendering in the wrong UI.

The changes are as follows.

- Modifies Core helper `Workarea::StyleGuidesHelper`
  - Modifies `partial_paths_for`
- Modifies Core helper `Workarea::StyleGuidesHelper::Partials`
  - Modifies `initialize`
  - Modifies `name_from`
  - Modifies `pattern`
- Modifies Core helper test case `Workarea::StyleGuidesHelperTest`
  - Modifies `test_partial_paths`

## Disables HTTP Caching for Admins

[8fb7be433f6](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/8fb7be433f687a6cd905ceab475557820f85199c)

Workarea 3.0.11 disables HTTP caching when the current user is an admin.

The change modifies the Storefront controller (mixin) `Workarea::Storefront::HttpCaching`, changing `cache_page` to use HTTP cache only if the current user (if any) is not an admin.

## Fixes ID Data Types in User Activity

[2418f98526a](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/2418f98526a2e3ec95d98172db8fb4a593926c67)

Workarea 3.0.11 typecasts IDs within user activity to resolve an issue that surfaced in a new Storefront recent views API endpoint.

The following changes are applied.

- Modifies Core model `Workarea::Recommendation::UserActivity`
  - Modifies `self.prepend_field`
- Modifies Core model test case `Workarea::Recommendation::UserActivityTest`
  - Adds `test_id_typecasting`

## Fixes Display of Content Block Icons

[#2693](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2693/overview)

Workarea 3.0.11 modifies the following Admin views, replacing calls to `inline_svg` with `content_block_icon`. These changes ensure a fallback icon is used when a custom icon is not provided.

- workarea/admin/content/\_card.html.haml
- workarea/admin/content/\_edit.html.haml

## Fixes Clearing Hidden Breakpoints

[#2711](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2711/overview)

Workarea 3.0.11 modifies the Admin partial _workarea/admin/content/\_form.html.haml_ to fix the clearing of hidden breakpoints from a content block.

The change adds a `'block[hidden_breakpoints][]'` hidden field to ensure a value is submitted when all checkboxes are cleared.

## Fixes Exception in Inventory Status View Model

[#2705](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2705/overview)

Workarea 3.0.11 fixes the Storefront inventory status view model to prevent raising an exception when no inventory sku is available.

The change modifies the Storefront view model `Workarea::Storefront::InventoryStatusViewModel`, changing `message` to return an empty string when no inventory sku is available. The change also adds a test, `test_message_none_available`, to the Storefront view model test case `Workarea::Storefront::InventoryStatusViewModelTest`.

## Fixes Duplicate DOM When Returning to Page

[#2700](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2700/overview), [#2701](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2701/overview)

Workarea 3.0.11 modifies several Admin JavaScript modules to prevent duplicate DOM nodes in the Admin when returning to a previously visited page. The changes, listed below, add a `destroy()` function, which is invoked before storing the DOM in the turbolinks cache.

- Modifies Admin JavaScript module `WORKAREA.tabs`
  - Adds `destroy()`
  - Adds event listener `$(document).on('turbolinks:before-cache', destroy);`
- Modifies Admin JavaScript module `WORKAREA.publishWithReleaseMenus`
  - Adds `destroy()`
  - Adds event listener `$(document).on('turbolinks:before-cache', destroy);`
- Modifies Admin JavaScript template `workarea/admin/templates/new_release_option.jst.ejs`

## Fixes Display of Package Creation Time in Fulfillment Admin

[#2717](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2717/overview)

Workarea 3.0.11 replaces a plain text Admin translation with an HTML translation in order to fix the display of package creation time in the fulfillment Admin screen.

The following changes are applied.

- Modifies Admin locale file _config/locales/en.yml_
  - Removes translation `workarea.admin.fulfillments.show.on_time_created`
  - Adds translation `workarea.admin.fulfillments.show.on_time_created_html`
- Modifies Admin view _workarea/admin/fulfillments/show.html.haml_

## Changes Precompile Asset Paths

[25e8cd4a072](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/25e8cd4a072bea40748b9550037586267fe0294c)

Workarea 3.0.11 modifies the list of precompile asset paths in `Rails.application.config.assets.precompile`, removing the globs _workarea/admin/\*.svg_ and _workarea/storefront/\*.svg_, and adding _workarea/\*\*/\*.svg_. The changes occur in the Core initializer `workarea-core/config/initializers/02_assets.rb` and intend to include all SVG files as precompiled assets.

## Adds Styles & Style Guide for Admin Chart Legends

[#2699](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2699/overview)

Workarea 3.0.11 adds styles and a style guide for the Admin _chart-legend_ component.

The PR makes the following changes.

- Adds Admin component stylesheet _workarea/admin/components/\_chart\_legend.scss_, which implements:
  - `$chart-legend-dot-size`
  - `.chart-legend {}`
  - `.chart-legend__item {}`
  - `.chart-legend__color-dot {}`
  - `.chart-legend__label {}`
- Modifies Admin stylesheet manifest _workarea/admin/application.scss.erb_ (to add the above stylesheet)
- Adds Admin style guide partial _workarea/admin/style\_guides/components/\_chart\_legend.html.haml_

## Adds Store Credit Card Test Case

[#2713](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2713/overview)

Workarea 3.0.11 adds the Core model test case `Workarea::Payment::StoreCreditCardTest`, which inherits from `Workarea::TestCase` and implements:

- `credit_card_gateway`
- `credit_card` (setup)
- `test_perform_does_nothing_if_credit_card_already_has_a_token`
- `test_perform_stores_on_the_gateway`
- `test_perform_sets_the_token_on_the_credit_card`
- `test_save_persists_the_token`

The test case was converted from Workarea's remaining RSpec test suite.

## Fixes Style Guide Generator Documentation

[#2714](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/2714/overview)

Workarea 3.0.11 updates the documentation for the style guide generator in _workarea-core/lib/generators/workarea/style\_guide/USAGE_ to reflect changes in effect since Workarea 3.0.

The example below shows the updated documentation.

```bash
$ bin/rails g workarea:style_guide
Usage:
  rails generate workarea:style_guide ENGINE SECTION NAME [options]

Runtime options:
  -f, [--force] # Overwrite files that already exist
  -p, [--pretend], [--no-pretend] # Run but do not make any changes
  -q, [--quiet], [--no-quiet] # Suppress status output
  -s, [--skip], [--no-skip] # Skip files that already exist

Options:
  ENGINE is either:
    - admin
    - storefront

  SECTION is an existing section, the workarea gem offers these sections out of the box:
    - settings
    - base
    - typography
    - objects
    - components
    - trumps

  NAME is the name of your partial, separated with dashes:
    - button
    - button--large
    - table--prices

Description:
  Creates a new Style Guide entry for your application.

Examples:
  rails g workarea:style_guide storefront components button
  rails g workarea:style_guide admin components button--large
```
