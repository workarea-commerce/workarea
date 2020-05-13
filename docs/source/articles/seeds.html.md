---
title: Seeds
created_at: 2018/08/07
excerpt: Seeds are default data appropriate for developing, testing, or otherwise using a Workarea application, particularly in a development environment. Seeding is the process of writing the seeds within a particular environment.
---

# Seeds

_Seeds_ are default data appropriate for developing, testing, or otherwise using a Workarea application, particularly in a development environment. _Seeding_ is the process of writing the seeds within a particular environment.

**Be careful!:** Seeding is a destructive process that purges all existing MongoDB and Elasticsearch data before writing. Be certain you are willing to lose all data before running seeds in an environment.

Seeding is performed exclusively through a command line interface. To seed an environment, bundle the application and run the _db:seed_ task:

```bash
cd <your_application_directory>
bundle
bin/rails db:seed
```

See below for a detailed example.

The base platform includes the seeds necessary to use a generic Workarea application. Plugins and applications can extend seeds as necessary to support platform customizations. (I'll cover seeds implementation and extension in detail in a future guide.)

## Seeding a New Development Environment

To demonstrate seeds, consider a fictional, newly created Workarea application named _Boardgamz_.

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

![Before seeding](/images/before-seeding.png)

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

![After seeding](/images/after-seeding.png)

### Admin Access

Seeding also provides access to the Admin, which is displaying order and analytics data that was also seeded:

![Seeded Admin](/images/seeded-admin.png)

Refer to [`AdminSeeds#perform`](https://github.com/workarea-commerce/workarea/blob/master/core/app/seeds/workarea/admins_seeds.rb) in your instance of Workarea for administrator emails and passwords to log in to the Admin.


## Re-Seeding

The seeds included with Core use some random data, so seeding is not idempotent. However, re-seeding should produce data that is uniform—having the same general “shape”—each time.

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

![After re-seeding](/images/after-re-seeding.png)

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

As an application developer, you can define your own seeds. You can also [decorate](/articles/decoration.html) and [configure](/articles/configuration.html) existing seeds. This provides the flexibility to add, modify, replace, and remove seeds to better suite the requirements of your application.

### Remove Seeds

To remove seeds, you can add the following to the application's `workarea.rb` initializer:

```ruby
Workarea.configure do |config|
  config.seeds.delete('Workarea::CustomersSeeds')
end
```

### Modify Seeds

If you only want to make minor tweaks to how existing seeds work, you can decorate seed files like any other Workarea class:

```ruby
# app/seeds/workarea/discounts_seeds.decorator
module Workarea
  decorate DiscountsSeeds, with: :your_app do
    def perform
      super

      # Add new seeded discounts
    end
  end
end
```

### Add or Replace Seeds

Swapping existing seeds for your custom seed class or adding onto seeds both require two steps -- creating a new seed class, and editing the configuration. Workarea expects any seed class to respond to a `#perform` instance method

```ruby
# app/seeds/workarea/my_custom_seeds.rb
module Workarea
  class CustomCategorySeeds
    def perform
      puts 'Adding custom data...'

      # add custom seed data here
    end
  end
end
```

Once your seed class is created, you need to update the `Workarea.config.seeds` list to include your seeds in `config/initializers/workarea.rb`.

You can either add to existing seeds

```ruby
Workarea.config.seeds.append('Workarea::CustomCategorySeeds')
```

Or, if you are replacing an existing seed class you can swap the classes:

```ruby
Workarea.config.seeds.swap(
  'Workarea::CategoriesSeeds',
  'Workarea::CustomCategorySeeds'
)
```

## Plugin Seeds

Plugins typically add _new_ seeds, which support the other extensions applied within the plugin. For example, the blog plugin seeds blogs, entries, and comments; while the clothing and package products plugins seed additional products.

To see this, add some plugins to the application. Add the following lines to the Gemfile:

```ruby
gem 'workarea-blog'
gem 'workarea-gift_cards'
gem 'workarea-package_products'
gem 'workarea-wish_lists'
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
+Adding wish lists...

 == Loading Elasticsearch data
 Indexing storefront...
```

Additionally, count the products again:

```bash
$ bin/rails r 'puts Workarea::Catalog::Product.count'
103
```

If you compare the result to the same query above, you can see there are additional products in the database. These additional products include data to support the functionality of the package products and gift cards plugins. To boot, the reviews plugin adds rating and review data to some of the products. You can see some of these new products and additional data in the following view of the Storefront:

![Seeds from plugins](/images/seeds-from-plugins.png)

## Summary

- Seeds are default data, which make your application usable for development and generally consistent with the other developers on your team
- Seeding, performed from the command line, is the (destructive) process of writing seeds to an environment
- Re-seeding should produce uniform, but not identical, data each time
- You should re-seed your development environment as needed to resolve data issues and after you or another developer extends seeds or changes installed plugins
- Plugins often include their own seeds to support the plugins' other extensions to the platform
