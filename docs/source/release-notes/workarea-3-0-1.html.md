---
title: Workarea 3.0.1
excerpt: To ensure tests function correctly, Workarea must load before other gems when the application boots. The app template included in Workarea 3.0.1 has been updated to ensure this change is present in new applications. However, this change must be applie
---

# Workarea 3.0.1

## Loads Workarea Before Other Gems

To ensure tests function correctly, Workarea must load before other gems when the application boots. The app template included in Workarea 3.0.1 has been updated to ensure this change is present in new applications. However, this change must be applied manually to applications that were created using an earlier version of the app template. The code example below shows the correct loading order.

```
# /config/application.rb

# ...

# Workarea must be required before other gems to ensure control over Rails.env
# for running tests
require 'workarea/core'
require 'workarea/admin'
require 'workarea/storefront'

Bundler.require(*Rails.groups)

# ...
```

## Redesigns Z-Index Management

Workarea 3.0.1 adds stylesheets to the _settings_ layer in the Admin and Storefront which establish a new convention for specifying z-index values throughout both UIs. The pattern is described in the article [Sassy Z-Index Management For Complex Layouts](https://www.smashingmagazine.com/2014/06/sassy-z-index-management-for-complex-layouts/) and uses Sass lists to manage z-indexes.

For example, in the Storefront, to ensure the `page-header` block has a higher z-index than the `page-content` block, `page-header` is ordered after `page-content` in the `$page-container` list. The styles for `page-header` then use Sass's `index` function to find the position of `page-header` within the `$page-container` list and use that number as the z-index value.

```
// workarea-storefront/app/assets/stylesheets/workarea/storefront/settings/_z_indexes.scss

// ...

$page-container: (
    page-content,
    page-header
) !default;

// workarea-storefront/app/assets/stylesheets/workarea/storefront/components/_page_header.scss

// ...

.page-header {
    position: relative;
    z-index: index($page-container, page-header);
    // ...
}

// ...
```

Within each UI, there is one list per stacking context. Applications should use and maintain these lists to manage z-index values.

The change adds a _settings/\_z\_indexes.scss_ settings stylesheet to the Admin and Storefront and modifies the _application.scss.erb_ stylesheet manifest in each engine to import the new stylesheets. If either manifest in your application has been overridden, you'll need to edit the manifest to import the new settings.

Furthermore, various stylesheets are modified to ensure that each z-index value is specified using the `index` function to look up the position of a block within a list. Review the [merge commit](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/0705533c45887b9cab65c416effdf0fb138eda51) to see the complete list of affected files and update any overridden assets in your application accordingly.

## Moves Dialog and Loading Assets out of Core

Since Workarea 3.0.0, dialogs are no longer used in the Admin and the `WORKAREA.loading` JavaScript module is used exclusively in the Storefront. Workarea 3.0.1 therefore moves dialog and loading assets out of Core since the code is no longer shared across UIs. The only exception is the _loading.jst.ejs_ JavaScript template, which is duplicated within Admin and Storefront as of 3.0.1. The following list summarizes the relevant code changes.

- Move the _modules/dialog_, _modules/dialog\_buttons_, _modules/dialog\_forms_, and _modules/dialog\_close\_buttons_ JavaScript module files from Core to Storefront
- Remove the above modules from the Admin _application.js.erb_ manifest and update their paths in the Storefront manifest
- Additionally remove _jquery-ui/widgets/dialog_ from the Admin manifest
- Remove the _jquery\_ui/admin/\_ui\_dialog.scss_ stylesheet from the Admin
- Remove the _style\_guides/components/\_ui\_dialog.html.haml_ style guide partial from the Admin
- Remove all styles scoped to `.ui-dialog` within the _jquery\_select2/admin/theme/\_workarea.scss_, _workarea/admin/components/\_style\_guide.scss_, and _workarea/admin/components/\_view.scss_ Admin stylesheets
- Remove dialog Sass variables from _workarea/admin/settings/\_global.scss_ in the Admin
- Move the `WORKAREA.config.dialog` and `WORKAREA.config.loading` assignments from _workarea/core/config.js_ in Core to _workarea/storefront/config.js.erb_ in Storefront
- Copy the _workarea/admin/templates/loading.jst.ejs_ JavaScript template to Admin and Storefront, then remove it from Core
- Update the path to the above template within the _workarea/storefront/config.js.erb_ Storefront file
- Update the path to the above template within the _workarea/admin/modules/add\_content\_block\_buttons.js_ and _workarea/admin/modules/content\_blocks.js_ Admin files

Review the [merge commit](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/df92f6c3524bf1cd91ad46b5564572a175ab7590) for a diff of the above changes.

## Adds Product Entries Query

Workarea 3.0.1 adds a new query class, `Workarea::Search::ProductEntries`, which creates a collection of search models (to be indexed into Elasticsearch) from the given collection of product models. By default, initializing a `ProductEntries` collection creates a `Search::Storefront::Product` to represent each of the given products. However, plugins and applications may need to modify this logic.

For example, the <cite>Workarea Package Products</cite> plugin conditionally represents a given product using its own `Search::Storefront::PackageProduct` model instead of the default `Search::Storefront::Product` search model.

Furthermore, the <cite>Workarea Browse Option</cite> plugin extends the `ProductEntries` collection to potentially contain multiple search documents for each product (one per a given product option, such as color or size). Each product in the collection is represented by one or more instances of `Search::Storefront::ProductOption`, a search model provided by the plugin.

Plugins and applications can extend this class as needed to ensure products are represented appropriately in Elasticsearch.

## Adds Credit Card Icons Helper Method

Workarea 3.0.1 adds the `Workarea::Storefront::CreditCardsHelper#all_payment_icons` helper method, which returns the markup needed to display a collection of icons representing the accepted credit card types, as declared in `Workarea.config.credit_card_issuers`.

The output of this helper replaces the `workarea.storefront.checkouts.credit_card_types` translation within the _workarea/storefront/checkouts/payment.html.haml_ view in the Storefront. If your application has overridden this view, you must apply this change manually.

The following image shows the icons displayed in the Storefront.

![credit card icons](images/credit-card-icons.png)

## Adds HTML Data Attributes Option for Content Fields

Workarea 3.0.1 adds an `html_data_attributes` option to [content fields](content.html#field). Content field options are declared using the [content block DSL](content.html#content-block-dsl). The `html_data_attributes` option outputs the given data attributes on the _property_ component for that field within the Admin UI.

The following example extends the _Text_ block type to include the `data-baz="qux"` and `data-foo="bar"` data attributes on the _Text_ field's property component in the Admin.

```
# Within any initializer, such as /config/initializers/workarea.rb

Workarea::Content.define_block_types do
  block_type 'Text' do
    field 'Text', :text, html_data_attributes: { foo: 'bar', baz: 'qux' }
  end
end
```

```
<!-- HTML ouput in the Admin UI -->

<div class="property" data-baz="qux" data-foo="bar">
  <label class="property__name" for="text_content_block">Text</label>
  <div class="wysiwyg" data-wysiwyg>
    <!-- ... -->
  </div>
</div>
```

## Adds Color Picker Component to Admin (for Color Fields)

Workarea 3.0.1 adds a _color-picker_ component to the Admin and applies the component to _color_ [content fields](content.html#field) (`Workarea::Content::Fields::Color`).

The image below shows the style guide for the new component.

![color picker component Admin style guide](images/color-picker-component-admin-style-guide.png)

And the following image shows the component in use within a content editing screen.

![color picker component on content editing screen](images/color-picker-component-on-content-editing-screen.png)

The following list summarizes the code changes within the Admin.

- Adds _components/\_color\_picker.scss_ component stylesheet
- Modifies _application.scss.erb_ manifest to import _\_color\_picker.scss_
- Adds _style\_guides/components/\_color\_picker\_field.html.haml_ style guide partial
- Modifies _content\_blocks/\_color.html.haml_ partial to apply the _color-picker_ component to _color_ fields

If any of the above stylesheets or partials have been overridden in the application you're upgrading, you'll need to apply the changes manually within your copy of the files.

## Adds Style Guides Navigation

Workarea 3.0.1 adds navigation to the style guides indexes for the Admin and Storefront.

The image below shows the navigation within the Admin.

![Admin style guides navigation](images/admin-style-guides-navigation.png)

And the following image shows the navigation within the Storefront.

![Storefront style guides navigation](images/storefront-style-guides-navigation.png)


