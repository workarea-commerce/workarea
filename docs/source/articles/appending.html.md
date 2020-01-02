---
title: Appending
created_at: 2018/12/05
excerpt: Appending is an extension technique whereby plugins and applications inject their own partials, stylesheets, and JavaScript into designated areas within Workarea UIs.
---

# Appending

_Appending_ is an [extension](/articles/extension-overview.html) technique whereby plugins and applications inject their own partials, stylesheets, and JavaScript into designated areas within Workarea UIs.

## General Concepts

Workarea provides uniquely identified <dfn>append points</dfn> within views and asset manifests to which plugins and applications may append their own files, which are informally referred to as <dfn>appends</dfn>. The mappings of appends to append points are stored in <dfn>appends hashes</dfn>.

### Append Points

The following helper methods are used within Workarea views and asset manifests to declare append points.

- `Workarea::PluginsHelper#append_partials` to provide append points within views
- `Workarea::Plugin::AssetAppendsHelper#append_stylesheets` to provide append points within stylesheet manifests
- `Workarea::Plugin::AssetAppendsHelper#append_javascripts` to provide append points within JavaScript manifests

These methods each take an argument to provide a name for the append point, which is namespaced to a particular UI, and `append_partials` takes an additional argument for local variables. The behavior of each is slightly different, so review the details and examples for each type of append, below.

Append points are generally provided by the _base platform_ for use by plugins and applications. However, in some cases a plugin may also want to provide append points to allow it to be extended by other plugins and applications.

### Appends

Appends are the files a plugin or application assigns to particular append points within the platform. Plugins and applications use the following methods to declare the mappings of appends to append points.

- `Workarea::Plugin.append_partials` to assign one or more partials to an append point within a view
- `Workarea::Plugin.append_stylesheets` to assign one or more stylesheets to an append point within a stylesheet manifest
- `Workarea::Plugin.append_javascripts` to assign one or more JavaScript files to an append point within a JavaScript manifest

Each of these methods takes a variable number of arguments, where the first argument is the name of the append point and the additional arguments are paths to appends. See the examples below for details.

The methods above are also accessible via the aliases `Workarea.append_partials`, `Workarea.append_stylesheets`, and `Workarea.append_javascripts`. These aliases are the preferred form when used in applications.

### Appends Hashes

Three appends hashes store the lists of appends that have been assigned to append points, grouped by append point name. These hashes are directly accessible via the following APIs.

- `Workarea::Plugin.partials_appends`
- `Workarea::Plugin.stylesheets_appends`
- `Workarea::Plugin.javascripts_appends`

Each method above returns a hash where each key is the name of an append point, and each value is an ordered list of files assigned to that append point. Each file is identified by a logical path—see the following sections for more on this. The example below looks at the partials appends hash within my demonstration app, which has several plugins installed.

```ruby
Workarea::Plugin.partials_appends
# => {"admin.primary_nav"=>["workarea/admin/blog/menu"], "admin.dashboard.index.navigation"=>["workarea/admin/blog/dashboard_navigation"] ...
```

The following view of the same data is easier to read and shows the appends nested under their append points.

```ruby
puts Workarea::Plugin.partials_appends.sort.to_yaml.gsub('-', ' ')
#
# admin.catalog_product_aux_navigation
# workarea/admin/reviews/catalog_products_aux_link
# admin.catalog_product_cards
# workarea/admin/catalog_products/packaged_products_card
# workarea/admin/catalog_products/swatches_card
# admin.dashboard.index.navigation
# workarea/admin/blog/dashboard_navigation
# admin.marketing_menu
# workarea/admin/reviews/menu
# admin.primary_nav
# workarea/admin/blog/menu
# admin.product_attributes_card
# workarea/admin/catalog_products/browse_option_attribute_card
# admin.product_bulk_update_settings
# workarea/admin/bulk_action_product_edits/browse_option_field
# admin.product_fields
# workarea/admin/catalog_products/browse_option_field
# workarea/admin/catalog_products/clothing_fields
# admin.product_index_actions
# workarea/admin/catalog_products/create_package_button
# admin.releasable_models
# workarea/admin/content_blog_entries/releasable_model
# storefront.above_search_results
# workarea/storefront/searches/search_type_toggle
# storefront.product_details
# workarea/storefront/products/reviews_aggregate
# workarea/storefront/products/share
# storefront.product_show
# workarea/storefront/products/reviews
# storefront.product_summary
# workarea/storefront/products/reviews_summary
# workarea/storefront/products/clothing_summary
# storefront.style_guide_product_summary
# workarea/storefront/style_guides/reviews_product_summary_docs
# workarea/storefront/style_guides/clothing_product_summary_docs
```

## Details & Examples

The following sections cover additional details and provide examples for each append type.

### Appending Partials

When a Workarea application renders a view which contains append points, each invocation of `append_partials` looks in the partials appends hash for the partials assigned to that append point. The paths assigned to the append point are then rendered in the order in which they appear in the hash. The paths must therefore be in a format that Rails' `render` helper can resolve. Paths are typically specified relative to _engine\_root/app/views/_ and the leading underscore and trailing extension are omitted from the file's basename (see examples above).

Additionally, each rendered partial has access to the local variables provided as the second argument to that specific append point.

For example, review the following Storefront product template excerpt. Following the add-to-cart form is the _storefront.product\_details_ append point, to which the partial passes its local variable `product`. Each partial rendered here by `append_partials` has access to this local variable.

```ruby
/ workarea-storefront-3.1.1/app/views/workarea/storefront/products/templates/_generic.html.haml

    = form_tag cart_items_path, method: 'post', class: 'product-details__add-to-cart-form', /...
      / ...

        %p.product-details__add-to-cart-action= button_tag, /...

      / ...

    = append_partials('storefront.product_details', product: product)
```

Workarea Reviews, which I've installed in my demonstration app, includes a partial which is appended to the above append point. The partial, shown below, makes use of the `product` variable.

```ruby
/ workarea-reviews-2.1.0/app/views/workarea/storefront/products/_reviews_aggregate.html.haml

- if product.has_reviews?
  .reviews-aggregate{ itemprop: 'aggregateRating', itemscope: true, itemtype: 'http://schema.org/AggregateRating' }
    = link_to "#{product_path(product, product.browse_link_options)}#reviews", data: { scroll_to_button: '' }, class: 'reviews-aggregate__rating-link' do
      = rating_stars(product.average_rating, aggregate: true)

      / ...
```

Similarly, Workarea Share, which I've also installed, provides a partial for this append point. That partial also makes use of the `product` variable.

( This partial immediately renders another partial called _share\_buttons_, but the share buttons partial expects the `share_url` and `sku` local variables to be present, so values must be constructed for those variables using the value of `product`. )

```ruby
/ workarea-share-1.1.0/app/views/workarea/storefront/products/_share.html.haml

= render 'workarea/storefront/shares/share_buttons', share_url: share_product_url(product, sku: product.options[:sku]), /...
```

Each of these plugins also provides an initializer which calls `Workarea::Plugin.append_partials` to assign the partial within the plugin to the append point within the Storefront.

```ruby
# workarea-reviews-2.1.0/config/initializers/append_points.rb

module Workarea
  # ...

  Plugin.append_partials(
    'storefront.product_details',
    'workarea/storefront/products/reviews_aggregate'
  )

  # ...
end

# workarea-share/config/initializers/appends.rb

Workarea.append_partials(
  'storefront.product_details',
  'workarea/storefront/products/share'
)

# ...
```

When my application boots, Reviews loads before Share because Reviews appears earlier in my Gemfile. The Reviews initializer is therefore loaded before the Share initializer, and the Reviews partial is appended first. The following example shows the state of this append point within the appends hash.

```ruby
Workarea::Plugin.partials_appends['storefront.product_details']
# => ["workarea/storefront/products/reviews_aggregate", "workarea/storefront/products/share"]
```

Browsing to a page that renders the above Storefront template reveals the result: review stars and share buttons rendered below the product form.

![Appended rating stars and share buttons](/images/reviews-summary-above-share-buttons.png)

### Appending Assets

The same concepts apply when appending stylesheets and JavaScript files to asset manifests. Within manifests, calls to `append_stylesheets` and `append_javascripts` denote append points.

Within a stylesheet manifest, stylesheets are included via `@import` statements. The `append_stylesheets` method therefore finds all appends for the given append point and constructs an `@import` for each. Paths to stylesheet appends are therefore specified as any path that Sass's `@import` can resolve. Paths are typically specified relative to _engine\_root/app/assets/stylesheets/_, and the leading underscore and trailing extension are omitted from the basename. See examples below.

In a similar fashion, JavaScript files are included in a JavaScript manifest using `require_asset` statements. The `append_javascripts` method therefore constructs a `require_asset` statement for each JavaScript append within each append point. JavaScript paths are specified as any path that Sprockets' `require_asset` can resolve. Paths are typically specified relative to _engine\_root/app/assets/javascripts/_, and the trailing extension is omitted from the basename.

I'll re-use my app from above and the Reviews plugin to demonstrate asset appending.

The Storefront stylesheet manifest provides the _storefront.components_ append point, which allows plugins and applications to append additional component stylesheets after the Storefront's own components.

```ruby
<%# workarea-storefront-3.1.1/app/assets/stylesheets/workarea/storefront/application.scss.erb %>

<%# ... %>

@import 'workarea/storefront/components/pagination';
@import 'workarea/storefront/components/svg_icon';
@import 'workarea/storefront/components/sitemap';
@import 'workarea/storefront/components/sitemap_pagination';
<%= append_stylesheets('storefront.components') %>

<%# ... %>
```

And the Storefront JavaScript manifest provides the _storefront.modules_ append point, which allows plugins and applications to append additional JavaScript module files after the Storefront's own modules.

```ruby
<%# workarea-storefront-3.1.1/app/assets/javascripts/workarea/storefront/application.js.erb %>

<%
  # ...
  %w(
    # ...
    workarea/storefront/modules/recommendations_placeholders
    workarea/storefront/modules/recent_views
    workarea/storefront/modules/workarea_analytics
    workarea/storefront/modules/mobile_nav_button
  ).each do |asset|
    require_asset asset
  end

  # ...

  append_javascripts('storefront.modules')
%>

<%# ... %>
```

Workarea Reviews includes five Storefront component stylesheets and three Storefront modules. The plugin uses an initializer to append these stylesheets and JavaScript files to the append points shown above.

```ruby
# workarea-reviews-2.1.0/config/initializers/append_points.rb

module Workarea
  # ...

  Plugin.append_stylesheets(
    'storefront.components',
    'workarea/storefront/reviews/components/product_summary',
    'workarea/storefront/reviews/components/rating',
    'workarea/storefront/reviews/components/reviews',
    'workarea/storefront/reviews/components/reviews_aggregate',
    'workarea/storefront/reviews/components/write_review',
  )

  # ...

  Plugin.append_javascripts(
    'storefront.modules',
    'workarea/storefront/reviews/modules/product_review_ajax_submit',
    'workarea/storefront/reviews/modules/product_reviews_sort_menus',
    'workarea/storefront/reviews/modules/rating_buttons',
  )

  # ...
end
```

Booting my app and examining the appends hashes reveals the five Reviews stylesheets and the three Reviews JS modules are present.

```ruby
puts Workarea::Plugin.stylesheets_appends['storefront.components'].grep(/reviews/)
# workarea/storefront/reviews/components/product_summary
# workarea/storefront/reviews/components/rating
# workarea/storefront/reviews/components/reviews
# workarea/storefront/reviews/components/reviews_aggregate
# workarea/storefront/reviews/components/write_review

puts Workarea::Plugin.javascripts_appends['storefront.modules'].grep(/reviews/)
# workarea/storefront/reviews/modules/product_review_ajax_submit
# workarea/storefront/reviews/modules/product_reviews_sort_menus
# workarea/storefront/reviews/modules/rating_buttons
```

Furthermore, I can confirm the home page HTML contains script tags for the JavaScript files, and the compiled application manifest references the imported stylesheets.

(
Understanding these Unix command lines is not important.
But it _is_ important you know _where_ to look and _what_ to look for when things aren't working.
You can confirm these details equally well by inspecting the output manually in your browser.

The following examples depend on debugging output that is present in Rails' Development environment that may not be present in other environments.
)

```bash
$ curl -s 'http://10.10.10.10:3000' | # request home page
> grep 'reviews\/modules' | # find lines with 'reviews/modules'
> sed -e 's,/assets/workarea/storefront/, ... ,' -e 's,self-.*\.js?body=1,js ...,' # remove noise
<script src=" ... reviews/modules/product_review_ajax_submit.js ..."></script>
<script src=" ... reviews/modules/product_reviews_sort_menus.js ..."></script>
<script src=" ... reviews/modules/rating_buttons.js ..."></script>

$ curl -s 'http://10.10.10.10:3000/assets/workarea/storefront/application.css' | # request compiled manifest
> grep 'reviews\/components' | # find lines with 'reviews/components'
> sed 's/^.*\(reviews\/components\/_.*\.scss\).*$/\1/'| # remove noise
> uniq # remove duplicate lines
reviews/components/_product_summary.scss
reviews/components/_rating.scss
reviews/components/_reviews.scss
reviews/components/_reviews_aggregate.scss
reviews/components/_write_review.scss
```

### Appending from an Application

Appending from an application is no different than appending from a plugin. In the following examples, I append the files necessary to create a _loyalty-badge_ component in the Storefront. First I create the files to append: a style guide partial, a stylesheet, and a JavaScript module.

```bash
$ touch app/views/workarea/storefront/style_guides/components/_loyalty_badge.html.haml
$ touch app/assets/stylesheets/workarea/storefront/components/_loyalty_badge.scss
$ touch app/assets/javascripts/workarea/storefront/modules/loyalty_badge.js
```

Then I create an initializer to append the files to the appropriate append points.

```ruby
# config/initializers/appends.rb

Workarea.append_partials(
  'storefront.product_details',
  'workarea/storefront/style_guides/components/loyalty_badge'
)

Workarea.append_stylesheets(
  'storefront.components',
  'workarea/storefront/components/loyalty_badge'
)

Workarea.append_javascripts(
  'storefront.modules',
  'workarea/storefront/modules/loyalty_badge'
)
```

## Limitations & Workarounds

### Clearing the Application Assets Cache

At times, it may seem as though appended assets are not being applied to your application while developing. This occurs in environments where assets are compiled on the fly (such as Development), because Sprockets caches the compiled assets and loads the assets from this cache if no changes have occurred between requests. Changing appends hashes does not bust the Sprockets cache, so for example, if you install an additional plugin between requests, Sprockets is unaware the new plugin has appended additional assets and uses its existing cache.

To resolve this issue, you must clear your application's assets cache in _tmp/cache/assets_. You can delete the directory or use one of the Rake tasks Rails provides for this purpose.

The following example shows the _tmp_ directory of my demonstration app after browsing to the home page. I've limited the output to 4 levels since the assets cache is composed of a staggering number of directories and files.

```bash
$ find tmp -maxdepth 4
tmp
tmp/.keep
tmp/cache
tmp/cache/.gitkeep
tmp/cache/assets
tmp/cache/assets/sprockets
tmp/cache/assets/sprockets/v3.0
tmp/pids
tmp/restart.txt
tmp/sockets
```

Next, I used _rails -T_ to list the tasks Rails provides for managing the _tmp_ directory.

```bash
$ bin/rails -T tmp
rails tmp:clear # Clear cache and socket files from tmp/ (narrow w/ tmp:cache:clear, tmp:sockets:clear)
rails tmp:create # Creates tmp directories for cache, sockets, and pids
```

Finally, I ran the appropriate task to clear the assets cache, and then I listed the _tmp_ directory again to confirm the assets cache files were gone.

```bash
$ bin/rails tmp:cache:clear
$ find tmp -maxdepth 4
tmp
tmp/.keep
tmp/cache
tmp/cache/.gitkeep
tmp/pids
tmp/restart.txt
tmp/sockets
```

### Adding "Missing" Append Points

Another issue you may experience while developing (particularly plugins) is the append point you need does not exist in the platform. To resolve this, first try to find a "nearby" append point that you can use instead. Generally speaking, the placement of appends is inexact.

Applications can use [overriding](/articles/overriding.html) in place of or in addition to appending when precise placement of new code is required. For more on this, see Re-Positioning Partials within a View, below.

If you must use appending (e.g. you're developing a plugin) and there is no suitable append point for your needs, open a pull request that adds the new append point(s) to the platform. Platform append points are often added in patch releases, making the new append points available to all new and patched applications.

### Removing Appends from Append Points

**Workarea 3.2 added convenience methods for removing appends that improve the process described below.**

When developing applications, you may want to remove appends from append points. For example, in the image below, the reviews summary and share buttons are appended to _storefront.product\_details_ and rendered below the "Add to Cart" button. However, business requirements may call for the reviews summary to be removed from this particular view.

![Reviews summary above share buttons](/images/reviews-summary-above-share-buttons.png)

Prior to Workarea 3.2, there is no formal API to remove an append from an append point. However, you can manipulate the appends hashes directly. To prevent the reviews summary from displaying, you can remove that partial from that append point within the partials appends hash. The following initializer does the trick.

```ruby
# config/initializers/appends.rb

Workarea::Plugin.partials_appends['storefront.product_details']
  .delete('workarea/storefront/products/reviews_aggregate')
```

After rebooting the app and re-visiting the page, the reviews summary is gone.

![Reviews summary removed](/images/reviews-summary-removed.png)

Looking at the code example above, notice that I deleted a specific member of the array, referencing it by its value. When removing appends, do not reference them by index, since the indexes may change as you add, remove, and re-order the plugins you have installed.

Furthermore, always mutate the existing array rather than replacing its value entirely. This ensures that external changes to the appends hash (from adding/removing plugins or upgrading to newer versions) will cascade through to your application as intended.

#### Convenience Methods for Removing Appends

Workarea 3.2.0 [added convenience methods to remove appends](/release-notes/workarea-3-2-0.html#adds-convenience-methods-to-remove-appends), providing parity with the original methods for appending to appends hashes. These methods are

- `Workarea::Plugin.remove_partials`
- `Workarea::Plugin.remove_stylesheets`
- `Workarea::Plugin.remove_javascripts`

#### Removing Appends via Configuration

Since Workarea 3.4.0, applications may be configured to exclude appends from being added in the first place, by modifying the following config values:

```ruby
config.skip_partials = []
config.skip_stylesheets = []
config.skip_javascripts = []
```

The items in these arrays may be of type `String`, `RegExp` or `Proc`, giving a wider range of flexibility to the developer.

```ruby
config.skip_partials = [
  'workarea/storefront/products/reviews_aggregate',
  /wishlists/
]

config.skip_stylesheets = [
  Proc.new { |p| p.include?('reviews') }
]
```

### Re-Ordering Appends within an Append Point

Although less common than removing appends from append points, applications may also need to re-order the appends within an append point. For example, instead of removing the reviews summary like the example above, you may need to ensure the reviews summary is the last partial rendered within the _storefront.product\_details_ append point.

As with removing appends, there is no formal API for re-ordering appends, but you can accomplish the task by manipulating the appends hashes directly. The same caveats apply to re-ordering that applied to removing: reference each append by its value rather than its index, and mutate specific members, leaving the remainder of the array unchanged. One way to ensure a particular order under these constraints is to remove the appends for which order matters and push them back onto the array in the desired order.

For the particular example I described above, I needed to ensure the reviews summary is the last partial in its append point. The following initializer removes the append from the append point and then pushes it back onto the end of the array, ensuring it comes last.

```ruby
# config/initializers/appends.rb

Workarea::Plugin.partials_appends['storefront.product_details']
  .delete('workarea/storefront/products/reviews_aggregate')

Workarea::Plugin.partials_appends['storefront.product_details']
  .push('workarea/storefront/products/reviews_aggregate')
```

After a restart, the reviews summary renders below the share buttons.

![Reviews summary below share buttons](/images/reviews-summary-below-share-buttons.png)

You can manipulate the appends hashes as much as needed, however, anything more involved than the above example is likely going beyond the intended use cases for appending. [Overriding](/articles/overriding.html) provides more granular control over UI code, as demonstrated below.

### Re-Positioning Partials within a View

Partials may be appended only at the append points provided by the platform. Applications may need to move an entire append point or particular appends to another location within the DOM. To do so, you must [override](/articles/overriding.html) the view which contains the append point. Then, within that override, you can either move the entire append point, or you can remove particular partials from the append point and render them separately within the view override.

For example, your design may call for the reviews summary to be output below the product name and id, while the share buttons are to stay below the "Add to Cart" button. You can achieve this using an initializer to remove the partial from the append point, and an override to render the partial immediately following the `.product-details__name` element in the DOM.

The following initializer removes the append from the append point.

```ruby
# config/initializers/appends.rb

Workarea::Plugin.partials_appends['storefront.product_details']
  .delete('workarea/storefront/products/reviews_aggregate')
```

And the following diff shows the changes I made within my view override (see [Overriding](/articles/overriding.html) for more on that subject). When rendering the partials outside of the append point, be sure to pass through the same local variables provided by the append point (`product` in my example below).

```diff
diff --git a/app/views/workarea/storefront/products/templates/_generic.html.haml b/app/views/workarea/storefront/products/templates/_generic.html.haml
index 09579b2..a5725e8 100644
--- a/app/views/workarea/storefront/products/templates/_generic.html.haml
+++ b/app/views/workarea/storefront/products/templates/_generic.html.haml
@@ -4,12 +4,14 @@
     .product-details__name
       %h1{ itemprop: 'name' }= product.name

       %p.product-details__id
         %span{ itemprop: 'productID' }= product.id

+ = render 'workarea/storefront/products/reviews_aggregate', product: product
+
     .product-prices.product-prices--details{ itemprop: 'offers', itemscope: true, itemtype: 'http://schema.org/Offer' }
       = render 'workarea/storefront/products/pricing', product: product
```

The final result (after rebooting and reloading the page) is as follows.

![Reviews summary below product name](/images/reviews-summary-below-product-name.png)
