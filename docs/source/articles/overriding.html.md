---
title: Overriding
created_at: 2018/08/07
excerpt: Overriding is a UI extension technique where an application replaces views and assets from the platform with its own customized copies of the files. The replacement files—called overrides—allow HTML, CSS, and JavaScript sent to the browser to be exten
---

# Overriding

<dfn>Overriding</dfn> is a UI extension technique where an application _replaces_ views and assets from the platform with its own customized copies of the files. The replacement files—called <dfn>overrides</dfn>—allow HTML, CSS, and JavaScript sent to the browser to be extensively customized by the application.

An application can override platform views, layouts, and partials, as well as platform files served by the asset pipeline, such as stylesheets, JavaScript files, images, and fonts.

To override any of these files, simply copy the file to the same path within your application. Rails will render or serve your override instead of the original file from the platform. This works because when resolving paths, Action View and Sprockets both look for files within your application before looking in any Rails engines, including the Workarea engines.

## Example

UI customizations can be extensive, but I'll use a simple example to demonstrate the concept of overriding. By default, product pages in the Storefront display recommendations below the full product description. Refer to the following image.

![Storefront product page before overriding](/images/storefront-product-before-overriding.png)

The following example overrides the _products#show_ view in order to change the rendered HTML, moving the recommendations _above_ the product description.

### Identify the File to Override

Before you can create an override, you must identify the file you want to customize. In my case, the file is _app/views/workarea/storefront/products/show.html.haml_. I know this from experience, but there are a variety of ways to search for the file if you are less familiar with the composition of the Storefront.

For example, you can tail the Rails log while browsing to the page of interest. The following example demonstrates a simple search on the log to list recently rendered Haml files.

```bash
$ tail -f log/development.log | grep 'haml'
Rendered vendor/ruby/2.4.0/gems/workarea-reviews-2.1.0/app/views/workarea/storefront/products/_rating.html.haml (20.2ms)
Rendered vendor/ruby/2.4.0/gems/workarea-reviews-2.1.0/app/views/workarea/storefront/products/_reviews_summary.html.haml (35.0ms)
Rendered vendor/ruby/2.4.0/gems/workarea-clothing-2.1.0/app/views/workarea/storefront/products/_clothing_summary.html.haml (7.1ms)
Rendered vendor/ruby/2.4.0/gems/workarea-storefront-3.1.1/app/views/workarea/storefront/products/_summary.html.haml (274.9ms)
Rendered vendor/ruby/2.4.0/gems/workarea-storefront-3.1.1/app/views/workarea/storefront/recent_views/show.html.haml (329.8ms)
Rendering vendor/ruby/2.4.0/gems/workarea-storefront-3.1.1/app/views/workarea/storefront/products/show.html.haml within layouts/workarea/storefront/application
Rendered vendor/ruby/2.4.0/gems/workarea-storefront-3.1.1/app/views/workarea/storefront/products/_price.html.haml (5.8ms)
Rendered vendor/ruby/2.4.0/gems/workarea-storefront-3.1.1/app/views/workarea/storefront/products/_pricing.html.haml (19.7ms)
# ...
```

Or, inspect the DOM for a unique string, and search for that string within all installed Workarea engines. In my example, I observed the class value _product-detail-container_, which seemed like a good search term. As shown below, this reduced the list of candidates to three files (two of them views), a small enough set to review manually.

( I'm using Unix tools in my examples because they're universally available and are easy to represent in textual documentation. You should use whatever tools you are comfortable with for searching and browsing source code. )

```bash
$ grep -lr 'product-detail-container' $(bundle show --paths | grep 'workarea')</kbd>
/vagrant/board-game-supercenter/vendor/ruby/2.4.0/gems/workarea-package_products-3.1.0/app/views/workarea/storefront/products/package_show.html.haml
/vagrant/board-game-supercenter/vendor/ruby/2.4.0/gems/workarea-storefront-3.1.1/app/assets/stylesheets/workarea/storefront/components/_product_detail_container.scss
/vagrant/board-game-supercenter/vendor/ruby/2.4.0/gems/workarea-storefront-3.1.1/app/views/workarea/storefront/products/show.html.haml
```

### Copy the File into Your Application

Next, I create the necessary directory structure and copy the file into my application. The file path, relative to the engine root, is identical within the Storefront engine and my application.

```bash
$ mkdir -p app/views/workarea/storefront/products
$ cp vendor/ruby/2.4.0/gems/workarea-storefront-3.1.1/app/views/workarea/storefront/products/show.html.haml app/views/workarea/storefront/products
```

The override has now effectively replaced the original Storefront file, but the files are identical, so there is no observable difference in the application. It is a good idea to commit the new file to your application repository before changing it, so that the introduction of the file and the changes you make to it are recorded separately in your repository history.

```bash
$ git commit -m 'Override view' app/views/workarea/storefront/products/show.html.haml
```

### Customize the File

Now you can edit the file as necessary for your requirements. Be sure to edit the copy of the file within your application and not the original engine copy. For my example, I re-ordered the product description and recommendations, as shown in the diff below.

```diff
diff --git a/app/views/workarea/storefront/products/show.html.haml b/app/views/workarea/storefront/products/show.html.haml
index 1ef4ec4..6969e5e 100644
--- a/app/views/workarea/storefront/products/show.html.haml
+++ b/app/views/workarea/storefront/products/show.html.haml
@@ -27,11 +27,6 @@
       .product-details{ class: "product-details--#{@product.template}" }
         = render "workarea/storefront/products/templates/#{@product.template}", product: @product

- - if @product.description.present?
- .product-detail-container__description#description
- %h2.product-detail-container__description-heading= t('workarea.storefront.products.description')
- .product-detail-container__description-body{ itemprop: 'description' }!= @product.description
-
       - if @product.recommendations.any?
         %h2= t('workarea.storefront.recommendations.heading')

@@ -41,6 +36,11 @@
               .product-summary.product-summary--small{ itemprop: 'isRelatedTo', itemscope: true, itemtype: 'http://schema.org/Product' }
                 = render 'workarea/storefront/products/summary', product: product

+ - if @product.description.present?
+ .product-detail-container__description#description
+ %h2.product-detail-container__description-heading= t('workarea.storefront.products.description')
+ .product-detail-container__description-body{ itemprop: 'description' }!= @product.description
+
       %div{ data: { recommendations_placeholder: recent_views_path } }

       = append_partials('storefront.product_show', product: @product)
```

Browsing to the same page demonstrates the final result: the recommendations display above the product description.

![Storefront product page after overriding](/images/storefront-product-after-overriding.png)

## Override Generator

Workarea also provides an override generator, which you can use to create overrides for a given type and path. Run the generator with the _‑‑help_ option to view its documentation. The following example demonstrates running the command in Workarea 3.1.2.

```bash
$ bin/rails g workarea:override --help
Usage:
  rails generate workarea:override TYPE PATH [options]

Runtime options:
  -f, [--force] # Overwrite files that already exist
  -p, [--pretend], [--no-pretend] # Run but do not make any changes
  -q, [--quiet], [--no-quiet] # Suppress status output
  -s, [--skip], [--no-skip] # Skip files that already exist

Options:
  TYPE can be one of:
    - views
    - layouts
    - stylesheets
    - javascripts
    - images
    - fonts

Description:
  Generates application-specific overrides of Workarea front-end files

Examples:
  rails g workarea:override views workarea/storefront
  rails g workarea:override layouts workarea/storefront/application.html.haml
  rails g workarea:override layouts workarea/admin/application.html.haml
  rails g workarea:override stylesheets workarea/storefront/reviews
  rails g workarea:override stylesheets workarea/core/helpers/_respond_to.scss
  rails g workarea:override javascripts workarea/core/modules/string.js
  rails g workarea:override javascripts workarea/storefront/templates/btn.jst.ejs
  rails g workarea:override fonts workarea/storefront/icons.woff
  rails g workarea:override stylesheets jquery_ui/admin/_ui_dialog.scss
```

## Impact on Upgrades

Overrides provide enormous design flexibility, but they can affect the cost of upgrading your application to a newer release of the platform. Because your overrides maintain no relationship to the files they've replaced in the platform, changes to the files introduced by the platform will not be present in your application after upgrading. You will need to manually apply the same changes to your overrides if desired.

To mitigate this problem, Workarea provides _Workarea Upgrade_. Among its features, it will show diffs of Workarea changes for the files you've overridden in your application, easing the process of merging those changes into your overrides.

## Overrides within Plugins

Unlike other [extension](/articles/extension-overview.html) techniques, overriding is used almost exclusively by applications and is used by plugins in only rare cases. Although plugins are technically able to override files, it becomes problematic when other plugins or the application in which they are installed also want to override the same files. Plugins therefore override files only when they can assume they are the canonical source for the files, such as a theme plugin overriding the Storefront layout and assets.
