---
title: Add, Remove, Sort, and Group Storefront Search Filters
created_at: 2019/02/27
excerpt: Learn how to programmatically manipulate and customize rendering filters on the storefront
---

# Add, Remove, Sort, and Group Storefront Search Filters

In the course of developing a Workarea application, you may need to customize the UI for search filters on category browse and search results pages.

![Full example](/images/filters-all.png)

In this example, the filters shown are "Category", "Color", "Size", and "Price". Although "Category" is a special case, the "Color" and "Size" filters are configurable terms filters, while "Price" is exposed as a range filter.

You may need to add a new filter...

![Add new filter](/images/filters-material.png)

...remove an existing filter...

![Remove existing filter](/images/filters-omitted.png)

...sort them in a different order...

![Sort filters](/images/filters-sorted.png)

..."pin" the filter to the top of the page, treating it like a special case...

![Pin filter to the top of the page](/images/filters-pinned.png)

...or, arrange them into groups or some other custom design:

![Group filters together](/images/filters-groups.png)

This guide will show you how to do all of these things, and by the end of it, you'll be a Workarea filter expert!

## Etymology

Although the user sees these objects as "filters", you may see the word "facet" referring to the same feature, especially in the backend Ruby code (for example, the `Facet` class). The term "faceted search" is derived from Elasticsearch, which originally implemented a feature called "facets" (now replaced with "aggregations") that enabled filtering a resultset by various parameters. Workarea's implementation of filters echoes and compliments this functionality provided out-of-the-box by Elasticsearch. You'll see the terms "filter" and "facet" used interchangeably in this guide, but they refer to the same feature.

## Implementation

The API calls for the above customizations are mostly contained within the view model for the given page, so either `Storefront::SearchViewModel` or `Storefront::CategoryViewModel`. Workarea iterates over the `#facets` method for the view model in the view. This represents the collection of filters (as well as their returned data) in storefront search and category browse pages. These are the points at which one must extend in order to customize how filter display works.

The data for the `#facets` method is derived from the `#terms_facets` and `#range_facets` methods on `Search::Settings` and `Catalog::Category` (again, dependent on whether you're browsing a category or viewing search results).

To summarize, here are the relevant API calls for this guide:

- `Workarea::Storefront::SearchViewModel#facets`
- `Workarea::Storefront::CategoryViewModel#facets`
- `Workarea::Search::Settings#terms_facets`
- `Workarea::Search::Settings#range_facets`
- `Workarea::Catalog::Category#terms_facets`
- `Workarea::Catalog::Category#range_facets`

## Add a Search Filter

The attributes to filter on are enumerated in the site's global `Search::Settings` configuration, which is editable in the admin by visiting **/admin/search_settings**. There are two types of filters provided out-of-the-box for you, **Terms** filters and **Range** filters. Let's learn more about how to manipulate both kinds:

### Add a Terms Filter

Terms filters are completely configurable in the admin's "Search Settings" page, and require no developer assistance to configure. However, developers setting up an application for the very first time may want to decorate the `Workarea::SearchSettingsSeeds` from core to add their own filterable attributes like so:

```ruby
module Workarea
  decorate SearchSettingsSeeds do
    def perform
      Search::Settings.current.update_attributes!(
        terms_facets: %w(Color Size Material)
      )
    end
  end
end
```

This will result in the "Material" filter rendering on the storefront below "Color" and "Size", since that's the order they were configured in:

![Add new terms filter](/images/filters-material.png)

### Add a Range Filter

The only range filter provided out-of-the-box for you by Workarea is the "Price" filter. This is configurable through the admin, but requires developer intervention to customize the admin UI so the data for these filters can be entered in.

First, configure the range facet within search settings:

```ruby
module Workarea
  decorate SearchSettingsSeeds do
    def perform
      Search::Settings.current.update_attributes!(
        range_facets: %w(Price Height)
      )
    end
  end
end
```

Also, ensure that the search mapper for storefront products knows about the height and treats it as a numeric field.

```bash
$ bin/rails generate workarea:decorator app/models/workarea/search/storefront/product.rb
```

```ruby
module Workarea
  decorate Search::Storefront::Product do
    def height
      model.filters['Height'].first || 0
    end

    def numeric
      super.merge(height: height)
    end
  end
end
```

Optionally, define some tests in **test/models/workarea/search/storefront/product_test.decorator** for the new method(s) you've added:

```ruby
require 'test_helper'

module Workarea
  decorate Search::Storefront::ProductTest, with: :store do
    def test_height
      product = create_product(filters: { 'Height' => [6] })
      mapper = Search::Storefront::Product.new(product)

      assert_equal(mapper.height, product.filters['Height'].first)
    end

    def test_numeric
      product = create_product(filters: { 'Height' => [6] })
      mapper = Search::Storefront::Product.new(product)

      assert_includes(mapper.numeric.keys, :height)
    end
  end
end
```

Run these tests against the rest of the tests in the file by performing the following command:

```bash
$ ./bin/rails test $(bundle show workarea-core)/test/models/workarea/search/storefront/product_test.rb
```

Next, extend the admin UI to allow admins to update the range filter values. First, you'll learn how to add this UI to the global search settings, then you'll learn how new range facets can be added to category edit pages.

To get started, decorate `Admin::SearchSettingsController` to output the data for your custom range facet:

```bash
$ bin/rails generate workarea:decorator app/controllers/workarea/admin/search_settings_controller.rb
```

Replace the generated file with:

```ruby
module Workarea
  decorate Admin::SearchSettingsController do
    def show
      super
      @height_facets = @settings.range_facets['height'] || []
    end
  end
end
```

You'll now need to update the markup to add the fields necessary for editing the various range values for the filter. The easiest way to do this is to override the **workarea/admin/facets/price_inputs** partial and _rename_ it to match your new filter, like **workarea/admin/facets/height_inputs**...

```bash
$ bin/rails generate workarea:override views workarea/admin/facets/_price_inputs.html.haml
$ cp app/views/workarea/admin/facets/_price_inputs.html.haml app/views/workarea/admin/facets/_height_inputs.html.haml
$ rm -f app/views/workarea/admin/facets/_price_inputs.html.haml
```

This Haml template includes code specific to filtering by price, so you'll need to go through the partial and change those spots to match your new filter:

```diff
@@ -1,5 +1,5 @@
 .property
-  = label_tag 'range_facets', t('workarea.admin.facets.price_inputs.height_ranges_label'), class: 'property__name'
+  = label_tag 'range_facets', t('workarea.admin.facets.price_inputs.price_ranges_label'), class: 'property__name'
   %table
     %thead
       %tr
@@ -10,14 +10,14 @@
         %tr
           %td
-            = currency_symbol
-            = text_field_tag 'range_facets[height][][from]', range['from'], title: t('workarea.admin.facets.price_inputs.from'), class: 'text-box text-box--small', id: "range_facets[height][][from][#{index}]"
created_at: 2019/02/27
+            = text_field_tag 'range_facets[price][][from]', range['from'], title: t('workarea.admin.facets.price_inputs.from'), class: 'text-box text-box--small', id: "range_facets[price][][from][#{index}]"
created_at: 2019/02/27
           %td
-            = currency_symbol
-            = text_field_tag 'range_facets[height][][to]', range['to'], title: t('workarea.admin.facets.price_inputs.to'), class: 'text-box text-box--small', id: "range_facets[height][][to][#{index}]"
created_at: 2019/02/27
+            = text_field_tag 'range_facets[price][][to]', range['to'], title: t('workarea.admin.facets.price_inputs.to'), class: 'text-box text-box--small', id: "range_facets[price][][to][#{index}]"
created_at: 2019/02/27
       %tr{ data: { cloneable_row: '' } }
         %td
-          = currency_symbol
-          = text_field_tag 'range_facets[height][][from]', nil, title: t('workarea.admin.facets.price_inputs.from'), class: 'text-box text-box--small'
created_at: 2019/02/27
+          = text_field_tag 'range_facets[price][][from]', nil, title: t('workarea.admin.facets.price_inputs.from'), class: 'text-box text-box--small'
created_at: 2019/02/27
         %td
-          = currency_symbol
-          = text_field_tag 'range_facets[height][][to]', nil, title: t('workarea.admin.facets.price_inputs.to'), class: 'text-box text-box--small'
created_at: 2019/02/27
+          = text_field_tag 'range_facets[price][][to]', nil, title: t('workarea.admin.facets.price_inputs.to'), class: 'text-box text-box--small'
created_at: 2019/02/27
```

To display this new markup on the search settings page, override the **workarea/admin/search_settings/show.html.haml** partial to render your new range filter:

```bash
$ bin/rails generate workarea:override views workarea/admin/search_settings/show.html.haml
```

Then, on line 60 of the overridden file...

```diff
.tabs__panel
  %h2.tabs__heading= t('workarea.admin.search_settings.show.filters.title')
  %p= t('workarea.admin.search_settings.show.filters.description')

  .property
    = label_tag 'terms_facets_list', t('workarea.admin.search_settings.show.filters.title'), class: 'property__name'
    = text_field_tag 'terms_facets_list', @settings.terms_facets_list, class: 'text-box'
    %span.property__note= t('workarea.admin.form.csv_field_note')

  = render 'workarea/admin/facets/price_inputs', facet: @price_facets
+ = render 'workarea/admin/facets/height_inputs', facet: @height_facets
```

Finally, create a new label for the field and restart your server:

```yaml
en:
  workarea:
    admin:
      facets:
        price_inputs:
          height_ranges_label: Height Ranges
```

The search settings page on admin will now look like this:

![Custom admin range filter fields](/images/admin-range-filters.png)

Now that you've added a range filter to global search settings, you'll need to add it to the category edit page in order to allow categories to override the global search settings. To do this, you'll follow a slightly different path than what was described above, but the concepts are the same.

Start off by decorating `Admin::CategoryViewModel`

```bash
$ bin/rails generate workarea:decorator app/view_models/workarea/admin/category_view_model.rb
```

Add a new method called `#height_facet`, similar to the `@height_facet` instance variable you created in the last exercise:

```ruby
module Workarea
  decorate Admin::CategoryViewModel do
    def height_facet
      @height_facet ||= price_facets['height'] || []
    end
  end
end
```

Then, override **workarea/admin/catalog_categories/edit.html.haml** to add your new inputs partial right after line 70:

```bash
$ bin/rails generate workarea:override views workarea/admin/catalog_categories/edit.html.haml
```

```diff
             = t('workarea.admin.catalog_categories.edit.filters_note_html', search_settings_link: link_to(t('workarea.admin.catalog_categories.edit.search_settings'), search_settings_path(anchor: 'filters-tab-panel')))

         = render 'workarea/admin/facets/price_inputs', facet: @category.price_facet
+        = render 'workarea/admin/facets/height_inputs', facet: @category.height_facet

         .grid.grid--huge
           .grid__cell.grid__cell--50.grid__cell--25-at-medium
```

Now, when you restart your server and refresh the category edit page in admin, you'll see your new range filter!

![Admin category range filter](/images/admin-category-range-filters.png)

Add in the ranges you wish to filter on, ensure there's product data for that filter, and then you'll be ready to show it on the storefront.

![Range filter example](/images/filters-range.png)

You may have to prevent the existing price filter from showing twice, as well:

```ruby
module Workarea
  decorate Storefront::CategoryViewModel, Storefront::SearchViewModel do
    def facets
      super.uniq(&:system_name)
    end
  end
end
```

## Remove a Search Filter

Filters can be omitted from display on the storefront by removing them from the search settings. But this will remove the filter from displaying at all. You may want to display the filter in certain cases, for example, on a category browse page but not on a search results page. To do this, you'll need to decorate the relevant view model. Here's an example of removing the price filter from category browse pages in **app/view_models/workarea/storefront/category_view_model.decorator**:

```ruby
module Workarea
  decorate Storefront::CategoryViewModel do
    def facets
      super.delete_if do |facet|
        facet.system_name == 'price'
      end
    end
  end
end
```

Before applying this decoration, filters might look like something like this:

![Before applying the decoration](/images/filters-control.png)

After the decoration is applied, you should see the price filter omitted on category pages...

![After applying the decoration (browse)](/images/filters-omitted.png)

...but not on search pages!

![After applying the decoration (search)](/images/filters-control.png)

## Sort Filters

Out of the box, Workarea provides the following default sort order for your filters:

1. Category (when searching)
2. Terms filters in the order they appear in the `Search::Settings#terms_facets` Array
3. Range filters in the order they appear in the `Search::Settings#range_facets` Array

Sorting filters can be done by manipulating the order that filters appear in the collection:

```bash
$ bin/rails generate workarea:decorator app/seeds/workarea/search_settings_seeds.rb
```

```ruby
module Workarea
  decorate SearchSettingsSeeds do
    def perform
      Search::Settings.current.update_attributes!(
        terms_facets: %w(Size Color) # original order was "Color", "Size"
      )
    end
  end
end
```

Your filters should now look something like this:

![Changing Size and Color Filter Sort](/images/filters-sorted.png)

### "Special Case" Sorting

It is also possible to sort filters programmatically in the codebase to treat these filters like a "special case", for example in the case of category filtering only applying on search pages, and always sticking to the top of the filter navigation. To do so, follow the logic in "Remove a Search Filter" to decorate the appropriate view models' `#facets` method. Here's an example of "pinning" the price filter to the top of the sidebar:

```ruby
module Workarea
  decorate Storefront::CategoryViewModel, Storefront::SearchViewModel do
    def facets
      all_facets = super
      pinned_facet = all_facets.find { |facet| facet.system_name == 'price' }

      return all_facets unless pinned_facet.present?

      [pinned_facet] + all_facets.delete_if { |facet| facet.system_name == 'price' }
    end
  end
end
```

This multiple decoration is best defined in the file **app/view_models/workarea/storefront/product_browsing.decorator**. While you can't actually decorate the `ProductBrowsing` module, this file path will be looked up if `ProductBrowsing` is decorated, and thus your multiple decorations will apply cleanly without the need to manually load them at app initialization.

Before applying this decoration, your filters might look like something like this:

![Before applying the decoration](/images/filters-control.png)

After the decoration is applied, you should see the price filters appearing first:

![After applying the decoration](/images/filters-pinned.png)

## Grouping Filters

A growing trend for retailers is to group multiple filters together in the UI. For example, a shoe retailer might want to express "Color" and "Material" within the same filter group, even though these are two distinct facets of the items in search results. In this example, you'll learn how to combine these filter values together visually, and call it "Style". To accomplish this, you'll need to override the **workarea/storefront/categories/show.html.haml** and **workarea/storefront/searches/show.html.haml** to render these filters in a slightly different way. To provide the data for this special filter group, you'll also need to override `Storefront::SearchViewModel` and `Storefront::CategoryViewModel`.

First, create a decorator at **app/view_models/workarea/storefront/product_browsing.decorator** to decorate and provide facet data for search & category browse:

```ruby
module Workarea
  decorate Storefront::CategoryViewModel, Storefront::SearchViewModel do
    def style_facet
      facets.find { |facet| facet.system_name == 'style' }
    end

    def facets_without_style
      facets.reject { |facet| facet.system_name == 'style' }
    end
  end
end
```

Create a new partial at **app/views/workarea/storefront/facets/_style.html.haml**, this is the partial that will be used to render your new grouped facet. Here's an example of what that might look like:

```haml
.result-filters__section{ class: "result-filters__section--style" }
  %h2= t('workarea.storefront.products.filter_title', name: 'Style')
  - [color_facet, material_facet].compact.each do |facet|
    %h3= facet.name
    %ul.result-filters__group
      - facet.results.each do |value_name, count|
        %li.result-filters__filter{ class: ('result-filters__filter--selected' if facet.selected?(value_name)) }
          = link_to facet_path(facet, value_name), rel: 'nofollow', class: 'result-filters__link' do
            = value_name.titleize
            - if facet.selected?(value_name)
              %strong.result-filters__remove= t('workarea.storefront.products.remove_filter')
            - else
              %span.result-filters__count (#{count})
```

It's heavily based on the out-of-box **workarea/storefront/facets/_terms.html.haml** partial, but includes two separate dependencies (`color_facet` and `material_facet`) rather than the general `facet` used in the terms filter.

Now that your partial is defined, you'll need a way to render it. Begin by generating overrides for the aforementioned views:

```bash
$ ./bin/rails generate workarea:override views workarea/storefront/categories/show.html.haml
$ ./bin/rails generate workarea:override views workarea/storefront/searches/show.html.haml
```

Finally, update the view to add your new facet. Here's an example of what the override to **workarea/storefront/searches#show** might look like:

```diff
diff --git a/storefront/app/views/workarea/storefront/searches/show.html.haml b/storefront/app/views/workarea/storefront/searches/show.html.haml
index d90fcb09a..99453b389 100644
--- a/storefront/app/views/workarea/storefront/searches/show.html.haml
+++ b/storefront/app/views/workarea/storefront/searches/show.html.haml
@@ -19,12 +19,18 @@
     %span.breadcrumbs__node{ itemprop: 'breadcrumb' }
       %span.breadcrumbs__text= @search.query_string

 - content_for :page_aside do
   - if @search.facets.any?
     .result-filters
-      - @search.facets.each do |facet|
+      - @search.facets_without_style.each do |facet|
         - unless @search.autoselected_filter?(facet.system_name)
-          = render "workarea/storefront/facets/#{facet.type}", facet: facet
+          - if facet.system_name == 'color' && @search.style_facet.present?
+            = render "workarea/storefront/facets/style", facet: facet, size_group: @search.style_facet
+          - else
+            = render "workarea/storefront/facets/#{facet.type}", facet: facet

 .view{ data: { analytics: search_results_view_analytics_data(@search).to_json } }

@@ -81,10 +87,12 @@
           .mobile-filters__content
             - if @search.facets.any?
               .result-filters
-                - @search.facets.each do |facet|
+                - @search.facets_without_style.each do |facet|
                   - unless @search.autoselected_filter?(facet.system_name)
-                    = render "workarea/storefront/facets/#{facet.type}", facet: facet
-
+                    - if facet.system_name == 'size' && @search.style_facet.present?
+                      = render "workarea/storefront/facets/style", facet: facet, size_group: @search.style_facet
+                    - else
+                      = render "workarea/storefront/facets/#{facet.type}", facet: facet
     .pagination{ data: { analytics: product_list_analytics_data("Search Results for \"#{@search.query_string}\"").to_json, pagination: pagination_data(@search.products),  back_to_top_button: '' } }
       .grid
         - @search.products.each_with_index do |product, position|
```

Make sure `Search::Settings#terms_facets` includes the "Material" filter, and your new grouped filter will render in the storefront!

![Filter groups](/images/filters-groups.png)

## Additional Considerations

The storefront search filter UI is heavily cached on category browse pages. Some changes you make may not be visible until those caches expire, which can be anywhere from 15 minutes (HTTP page cache) to 1 hour (fragment cache for category pages). For this reason, Workarea developers typically favor testing changes to the filter UI on the search pages, but some special cases may force you to test on the category pages. In these cases, it's best to wait for the cache to expire.
