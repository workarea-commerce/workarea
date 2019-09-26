---
title: Seeds
excerpt: Seeds are default data appropriate for developing, testing, or otherwise using a Workarea application, particularly in a development environment. Seeding is the process of writing the seeds within a particular environment.
---

# Seeds

<dfn>Seeds</dfn> are default data appropriate for developing, testing, or otherwise using a Workarea application, particularly in a development environment. <dfn>Seeding</dfn> is the process of writing the seeds within a particular environment.

Be careful! **Seeding is a destructive process** that purges all existing MongoDB and Elasticsearch data before writing. Be certain you are willing to lose all data before running seeds in an environment.

Seeding is performed exclusively through a command line interface. To seed an environment, bundle the application and run the db:seed task:

```bash
$ cd application_directory
$ bundle
$ bin/rails db:seed
```

See below for a detailed example.

The base platform includes the seeds necessary to use a generic Workarea application. Plugins and applications can extend seeds as necessary to support platform customizations. (I'll cover seeds implementation and extension in detail in a future guide.)

## Seeding a New Development Environment

To demonstrate seeds, consider the fictional Workarea application <cite>Boardgamz</cite>, newly created within a fresh [Workarea app](create-a-new-app.html).

### Before Seeding

This environment has no MongoDB databases, collections, or documents, except for the default _test_ and _local_ databases:

```bash
$ mongo --eval 'db.getMongo().getDBNames()'
MongoDB shell version: 3.2.5
connecting to: test
["local"]
$
```

And there are no Elasticsearch indexes or documents:

```bash
$ curl localhost:9200/_cat/indices?v
health status index uuid pri rep docs.count docs.deleted store.size pri.store.size
$
```

You can start the application within the development environment, but you can't do much with it:

![Before seeding](images/before-seeding.png)

There is no navigation and nothing to search for. There are no products, categories, or content to browse. The Admin is inaccessible because there are no users who can authenticate as administrators.

To use this application, you need data. If you're new to Workarea, you may be surprised how much data is required for a typical flow, such as the process of adding some products to the cart and checking out. This path requires at least a few model instances from each of the following business domains:

- Catalog
- Inventory
- Navigation
- Pricing
- Shipping
- Tax

Seeding provides an effective way to write this necessary data with little effort.

### Seeding

The following example demonstrates seeding the environment. The output will display progressively as the process runs.

```bash
$ bin/rails db:seed
== Setting up...
Deleting Elasticsearch indexes...
Cleaning MongoDB collections...
Flushing Redis database...
Ensuring MongoDB indexes...
Ensuring Elasticsearch indexes...

== Loading MongoDB data
Adding search settings...
Adding content emails...
Adding tax rates...
Adding shipping services...
Adding assets...
Adding categories...
Adding products...
Adding auxiliary pages...
Adding browsing pages...
Adding discounts...
Adding dynamic content...
Adding browsing navigation...
Adding customer service navigation...
Adding system content...
Adding admin users...
Adding customers...
Adding orders...
Adding inquiries...
Adding help articles...
Adding analytics...

== Loading Elasticsearch data
Indexing storefront...
Indexing admin...
Indexing help...

Success!
$
```

### After Seeding

After seeding, MongoDB contains a development database for the application

```bash
$ mongo --eval 'db.getMongo().getDBNames()'
MongoDB shell version: 3.2.5
connecting to: test
["boardgamz_development", "local"]
$
```

that holds many collections

```bash
$ mongo boardgamz_development --eval "db.getCollectionNames().length"
MongoDB shell version: 3.2.5
connecting to: boardgamz_development
61
$
```

some of which are listed below:

```bash
$ mongo boardgamz_development --eval "db.getCollectionNames().slice(0,20)"
MongoDB shell version: 3.2.5
connecting to: boardgamz_development
[
	"mongoid_audit_log_entries",
	"workarea_analytics_categories",
	"workarea_analytics_category_revenues",
	"workarea_analytics_discount_revenues",
	"workarea_analytics_discounts",
	"workarea_analytics_discounts_summaries",
	"workarea_analytics_filters",
	"workarea_analytics_last_four_weeks_searches",
	"workarea_analytics_navigations",
	"workarea_analytics_new_customers",
	"workarea_analytics_orders_summaries",
	"workarea_analytics_product_revenues",
	"workarea_analytics_products",
	"workarea_analytics_search_abandonment_rates",
	"workarea_analytics_searches",
	"workarea_analytics_signups",
	"workarea_analytics_users",
	"workarea_bulk_actions",
	"workarea_catalog_categories",
	"workarea_catalog_product_placeholder_images"
]
$
```

Likewise, Elasticsearch contains multiple indexes for the application

```bash
$ curl localhost:9200/_cat/indices?v
health status index uuid pri rep docs.count docs.deleted store.size pri.store.size
yellow open boardgamz_development_en_storefront D38474KwRS6oYndzWtjnrQ 5 1 140 4 964.9kb 964.9kb
yellow open boardgamz_development_en_help j5M7K9QrT1a109VIujukcg 5 1 52 0 1.2mb 1.2mb
yellow open boardgamz_development_en_admin 3fTuI3raSjePJU1IJvmBTw 5 1 762 0 2mb 2mb
$
```

which hold many documents:

```bash
$ curl localhost:9200/_cat/count?v
epoch timestamp count
1511905005 21:36:45 954
$
```

The upshot of this is a usable Storefront, complete with products, categories, content, navigation, and other data:

![After seeding](images/after-seeding.png)

### Admin Access

Seeding also provides access to the Admin, which is displaying order and analytics data that was also seeded:

![Seeded Admin](images/seeded-admin.png)

Refer to [`AdminSeeds#perform`](https://github.com/workarea-commerce/workarea/blob/master/core/app/seeds/workarea/admins_seeds.rb) in your instance of Workarea for administrator emails and passwords to log in to the Admin.


## Re-Seeding

The seeds included with Core use some random data, so seeding is not idempotent.&nbsp;<sup><a href="#notes" id="note-2-context">[1]</a></sup> However, re-seeding should produce data that is uniform—having the same general “shape”—each time.

To demonstrate, use Mongoid to query the number of products and the first product in the Boardgamz development database:

```bash
$ bin/rails r 'puts Workarea::Catalog::Product.count'
90
$ bin/rails r 'puts Workarea::Catalog::Product.first.name'
Heavy Duty Aluminum Knife
$
```

Now, re-seed. (Also capture the seeding output to a file and add it to the git index—this is for a future example.)

```bash
$ bin/rails db:seed > seeding_output
$ git add seeding_output
$
```

After seeding completes, query the products again. You end up with the same _number_ of products, but the products themselves are different.

```bash
$ bin/rails r 'puts Workarea::Catalog::Product.count'
90
$ bin/rails r 'puts Workarea::Catalog::Product.first.name'
Aerodynamic Linen Keyboard
$
```

As another example, the image below shows the Storefront after re-seeding. Comparing it to the Storefront image above, you can see the “Header Promo Body” is identical, while the navigation is similar but different:

![After re-seeding](images/after-re-seeding.png)

The uniformity of seeds makes them valuable for the following additional use cases:

- Generally synchronizing your development environment data with other developers on your team
- Loading data to support new features or extensions added by you or other developers on your team
- Updating default data after installing or removing plugins from your application
- Restoring your application data to a known-good state

It is therefore sensible to re-seed your development environment in the following situations:

- After you've added a feature or extension which includes seeds (to ensure the seeds are adequate)
- After changing which plugins are installed
- After merging changes from another developer where either of the above is applicable
- When experiencing issues in development that may be data-related

## Extending Seeds

As an application developer, you can define your own seeds. You can also [decorate](decoration.html) and [configure](configuration.html) existing seeds. However, these techniques depend on an understanding of how seeds are implemented, which I haven't covered yet.

Therefore, let's instead take a look at how your installed plugins affect your seeds. Plugins typically add _new_ seeds, which support the other extensions applied within the plugin. For example, the blog plugin seeds blogs, entries, and comments; while the clothing and package products plugins seed additional products.

To see this, add some plugins to the application, as shown in the following git patch:

```diff
diff --git a/Gemfile b/Gemfile
index 0efec88..b3f9095 100644
--- a/Gemfile
+++ b/Gemfile
@@ -45,4 +45,11 @@ end

 source 'https://gems.workarea.com' do
   gem 'workarea', '3.1.5'
+ gem 'workarea-blog', '3.1.1'
+ gem 'workarea-clothing', '2.1.3'
+ gem 'workarea-gift_cards', '3.2.1'
+ gem 'workarea-package_products', '3.1.2'
+ gem 'workarea-reviews', '2.1.0'
+ gem 'workarea-store_locator', '4.0.0'
+ gem 'workarea-wish_lists', '2.0.3'
 end
```

Bundle the app; then re-seed and capture the seeding output to the same file as above.

```bash
$ bundle
$ bin/rails db:seed > seeding_output
```

After seeding completes, diff the output file to see how the seeding output has changed after installing plugins:

```bash
$ git diff seeding_output
```

You should see several additions:

```diff
diff --git a/seeding_output b/seeding_output
index 1fc7ea7..7c4d768 100644
--- a/seeding_output
+++ b/seeding_output
@@ -16,6 +16,8 @@ Adding shipping services...
 Adding assets...
 Adding categories...
 Adding products...
+Adding package products...
+Adding clothing products...
 Adding auxiliary pages...
 Adding browsing pages...
 Adding discounts...
@@ -25,10 +27,17 @@ Adding customer service navigation...
 Adding system content...
 Adding admin users...
 Adding customers...
+Adding blogs...
+Adding blog entries...
+Adding blog comments...
 Adding orders...
 Adding inquiries...
 Adding help articles...
 Adding analytics...
+Adding gift cards...
+Adding reviews...
+Adding store locations...
+Adding wish lists...

 == Loading Elasticsearch data
 Indexing storefront...
```

Additionally, count the products again:

```bash
$ bin/rails r 'puts Workarea::Catalog::Product.count'
103
```

If you compare the result to the same query above, you can see there are additional products in the database. These additional products include data to support the functionality of the clothing, package products, and gift cards plugins. To boot, the reviews plugin adds rating and review data to _all_ products. You can see some of these new products and additional data in the following view of the Storefront:

![Seeds from plugins](images/seeds-from-plugins.png)

## Summary

- Seeds are default data, which make your application usable for development and generally consistent with the other developers on your team
- Seeding, performed from the command line, is the (destructive) process of writing seeds to an environment
- Re-seeding should produce uniform, but not identical, data each time
- You should re-seed your development environment as needed to resolve data issues and after you or another developer extends seeds or changes installed plugins
- Plugins often include their own seeds to support the plugins' other extensions to the platform

## Notes

[1] Of course, since seeds are extensible, you can write your own seeds to be idempotent if you so desire.
