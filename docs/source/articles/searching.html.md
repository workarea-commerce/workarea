---
title: Search
created_at: 2018/09/17
excerpt: Workarea applications persist model data to MongoDB, using it as the database of record. However, to provide near-real-time search, Workarea persists many of the same models to Elasticsearch, after first transforming them into a format suitable for se
---

# Search

Workarea applications persist model data to MongoDB, using it as the database of record. However, to provide near-real-time search, Workarea persists many of the same models to Elasticsearch, after first transforming them into a format suitable for search.

Workarea [callbacks workers](/articles/workers.html#callbacks-worker) enqueue in response to changes to Mongoid documents, and when run, these workers synchronize these data changes to Elasticsearch.

Workarea also provides query classes which encapsulate the complexity of the various search requests to Elasticsearch needed by Workarea applications. Each search query provides the search results for a given set of query parameters. Results are Mongoid models, initialized directly from a serialized copy in Elasticsearch, so it is not necessary to query MongoDB for results.

## Client & Server(s)

Workarea uses a [Ruby client](http://www.rubydoc.info/gems/elasticsearch-transport/5.0.5/Elasticsearch/Transport/Client) to communicate with an Elasticsearch [cluster](https://www.elastic.co/guide/en/elasticsearch/reference/5.6/_basic_concepts.html#_cluster). In Workarea Cloud environments, the Elasticsearch cluster is already provisioned. You must provision your own cluster in other environments.

The client instance, accessed as `Workarea.elasticsearch`, provides a [Ruby implementation](http://www.rubydoc.info/gems/elasticsearch-api/5.0.5/Elasticsearch/API) of the [Elasticsearch REST APIs](https://www.elastic.co/guide/en/elasticsearch/reference/5.6/index.html).

```ruby
Workarea.elasticsearch.class
# => Elasticsearch::Transport::Client
```

In normal operation, you will not use the client directly (favoring higher level APIs), however, direct access to the client is useful for debugging and other secondary use cases. The example below uses the client to print a simple status report for the entire cluster.

```ruby
puts Workarea.elasticsearch.cat.health(v: true, h: %w(cluster status))
# cluster status
# elasticsearch yellow
```

## Documents, Indexes, Types & Mappings

### Types

Elasticsearch uses [types](https://www.elastic.co/guide/en/elasticsearch/reference/5.6/_basic_concepts.html#_type) to categorize documents according to their fields, or [mappings](https://www.elastic.co/guide/en/elasticsearch/reference/5.6/mapping.html). Workarea uses four types out of the box:

- admin
- help
- storefront
- category

Workarea uses documents of type _category_ to index category queries for use with the [percolate query](https://www.elastic.co/guide/en/elasticsearch/reference/5.6/query-dsl-percolate-query.html), which can find the matching categories for a given product document. Because category documents are indexed and queried differently than the others, I do not cover them in this guide.

### Indexes

Documents of type _admin_, _help_, and _storefront_ are stored in separate indexes. Workarea applications use a varying number of Elasticsearch indexes. An index exists for each combination of site name, Rails environment, locale, and Elasticsearch document type.

( Documents of type _category_ are stored in the same indexes as documents of type _storefront_. )

For example, the indexes for a simple development application could be as follows.

- board\_games\_direct\_development\_en\_admin
- board\_games\_direct\_development\_en\_help
- board\_games\_direct\_development\_en\_storefront

Meanwhile, the following list of indexes could be used in an application with multiple site names (requires the _Multi Site_ plugin), environments, and locales.

- board\_games\_direct\_development\_en\_admin
- board\_games\_direct\_development\_en\_help
- board\_games\_direct\_development\_en\_storefront
- board\_games\_direct\_development\_es\_admin
- board\_games\_direct\_development\_es\_help
- board\_games\_direct\_development\_es\_storefront
- board\_games\_direct\_production\_en\_admin
- board\_games\_direct\_production\_en\_help
- board\_games\_direct\_production\_en\_storefront
- board\_games\_direct\_production\_es\_admin
- board\_games\_direct\_production\_es\_help
- board\_games\_direct\_production\_es\_storefront
- board\_games\_direct\_qa\_en\_admin
- board\_games\_direct\_qa\_en\_help
- board\_games\_direct\_qa\_en\_storefront
- board\_games\_direct\_qa\_es\_admin
- board\_games\_direct\_qa\_es\_help
- board\_games\_direct\_qa\_es\_storefront
- board\_games\_direct\_staging\_en\_admin
- board\_games\_direct\_staging\_en\_help
- board\_games\_direct\_staging\_en\_storefront
- board\_games\_direct\_staging\_es\_admin
- board\_games\_direct\_staging\_es\_help
- board\_games\_direct\_staging\_es\_storefront
- party\_games\_direct\_development\_en\_admin
- party\_games\_direct\_development\_en\_help
- party\_games\_direct\_development\_en\_storefront
- party\_games\_direct\_development\_es\_admin
- party\_games\_direct\_development\_es\_help
- party\_games\_direct\_development\_es\_storefront
- party\_games\_direct\_production\_en\_admin
- party\_games\_direct\_production\_en\_help
- party\_games\_direct\_production\_en\_storefront
- party\_games\_direct\_production\_es\_admin
- party\_games\_direct\_production\_es\_help
- party\_games\_direct\_production\_es\_storefront
- party\_games\_direct\_qa\_en\_admin
- party\_games\_direct\_qa\_en\_help
- party\_games\_direct\_qa\_en\_storefront
- party\_games\_direct\_qa\_es\_admin
- party\_games\_direct\_qa\_es\_help
- party\_games\_direct\_qa\_es\_storefront
- party\_games\_direct\_staging\_en\_admin
- party\_games\_direct\_staging\_en\_help
- party\_games\_direct\_staging\_en\_storefront
- party\_games\_direct\_staging\_es\_admin
- party\_games\_direct\_staging\_es\_help
- party\_games\_direct\_staging\_es\_storefront

### Mappings

Elasticsearch mappings are typically declared for an index when the index is created, however, the mapping may be extended at index time, such as when an index's mapping includes [dynamic templates](https://www.elastic.co/guide/en/elasticsearch/reference/5.6/dynamic-templates.html).

When creating a new index, Workarea looks for a configuration value declaring the mapping for that index. The configuration keys are named after the different document types. Each configured mapping includes _properties_ and _dynamic templates_.

( The _storefront_ key declares mappings for the _storefront_ **and** _category_ types, since both document types are stored in the same indexes. )

For example, the default configuration of the mappings for _storefront_ indexes are shown below.

```ruby
config.elasticsearch_mappings.storefront = {
  category: { properties: { query: { type: 'percolator' } } },
  storefront: {
    dynamic_templates: [
      {
        facets: {
          path_match: 'facets.*',
          mapping: { type: 'keyword' }
        }
      },
      {
        numeric: {
          path_match: 'numeric.*',
          mapping: { type: 'float' }
        }
      },
      {
        keywords: {
          path_match: 'keywords.*',
          mapping: { type: 'keyword' }
        }
      },
      {
        sorts: {
          path_match: 'sorts.*',
          mapping: { type: 'float' }
        }
      },
      {
        content: {
          path_match: 'content.*',
          mapping: { type: 'text', analyzer: 'text_analyzer' }
        }
      },
      {
        cache: {
          path_match: 'cache.*',
          mapping: { index: false }
        }
      }
    ],
    properties: {
      id: { type: 'keyword' },
      type: { type: 'keyword' },
      slug: { type: 'keyword' },
      suggestion_content: { type: 'string', analyzer: 'text_analyzer' }
    }
  }
}
```

Because the storefront mappings depend heavily on dynamic templates, the method `Workarea::Search::Storefront.ensure_dynamic_mappings` is available, which creates a product document, indexes it, and then removes it. This process helps reduce errors in a new environment where the index-time mappings have not been created yet.

### Document Interface

The `Workarea::Elasticsearch::Document` module provides a Ruby interface to represent behavior shared by Elasticsearch documents of _all_ types. Each class that includes this module represents a _specific_ type. Calling `Document.all` returns a list of the more specific classes.

```
puts Workarea::Elasticsearch::Document.all
# Workarea::Search::Admin
# Workarea::Search::Help
# Workarea::Search::Storefront
```

The classes listed above are used almost exclusively for _type_ and _index_ level concerns (see below), while the descendants of these classes (covered under Search Models) are used primarily for _document_ level concerns.

( `Workarea::Search::Help` has no descendants and is used directly to save and destroy documents. )

These classes respond to `.type` and `.mappings`, which describe the type of documents for which they are responsible. (Note that `.mappings` returns the Workarea configuration, not the actual mappings on the index.)

```ruby
Workarea::Elasticsearch::Document.all.map(&:type)
# => [:admin, :help, :storefront]

pp Workarea::Search::Help.mappings
# {:help=>
# {:dynamic_templates=>
# [{:facet_values=>
# {:path_match=>"facets.*",
# :mapping=>{:type=>"string", :analyzer=>"keyword"}}}],
# :properties=>
# {:id=>{:type=>"string", :index=>"not_analyzed"},
# :name=>{:type=>"string", :analyzer=>"text_analyzer"},
# :body=>{:type=>"string", :analyzer=>"text_analyzer"},
# :created_at=>{:type=>"date"}}}}
```

The following methods are used to create, delete, and reset all indexes for the particular document type. Remember that each document type may be stored on many indexes depending on the number of sites, environments, and locales.

- `.create_indexes!`
- `.delete_indexes!`
- `.reset_indexes!`

Every Elasticsearch document class has a <dfn>current index</dfn>. The example below demonstrates the current index is determined by the combination of current site name, Rails environment, locale, and document type.

```ruby
Workarea::Search::Storefront.current_index.name
# => "board_games_direct_development_en_storefront"

Workarea::Search::Storefront.current_index.url
# => "http://localhost:9200/board_games_direct_development_en_storefront"

Workarea.config.site_name
# => "Board Games Direct"

Rails.env
# => "development"

I18n.locale
# => :en

Workarea::Search::Storefront.type
# => :storefront
```

The current index is an instance of `Workarea::Elasticsearch::Index`, another abstraction provided by Workarea.

```ruby
Workarea::Search::Storefront.current_index.class
# => Workarea::Elasticsearch::Index
```

I do not cover this abstraction in detail because it is used internally and rarely invoked by application code. A Search model initializes instances of `Index` when needed and delegates index operations to its `current_index`.

## Indexing

Most search indexing is performed by [callbacks workers](/articles/workers.html#callbacks-worker) running in response to changes to application documents, and by workers run [on a schedule](/articles/workers.html#sidekiq-cron-job). Internally, workers use search models to transform the affected application documents into search documents, which involves serializing in-memory objects into strings. The search models then index the transformed documents into Elasticsearch.

To a lesser extent, rake tasks and seeds are also used to index documents for search.

### Workers

Various workers are used to index documents into Elasticsearch. Many of these are callbacks workers that run in response to life cycle changes on application documents (Mongoid documents) and use search models to forward Mongoid changes to Elasticsearch.

For example, review the implementation of `Workarea::IndexPage`, below.

```ruby
module Workarea
  class IndexPage
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker

    sidekiq_options(
      enqueue_on: { Content::Page => [:save, :destroy] },
      unique: :until_executing
    )

    def perform(id)
      page = Content::Page.find(id)
      Search::Storefront::Page.new(page).save
    rescue Mongoid::Errors::DocumentNotFound
      Search::Storefront::Page.new(
        Content::Page.new(id: id)
      ).destroy
    end
  end
end
```

when a `Workarea::Content::Page` is saved or destroyed, `Workarea::IndexPage` is enqueued with the id of the saved or destroyed content page. When this worker runs, it looks up the affected content page and creates an instance of `Search::Storefront::Page` from it. Then the worker uses `Search::Storefront::Page#save` or `Search::Storefront::Page#destroy` to create and index, or delete, the corresponding search document.

The `Workarea::IndexAdminSearch` worker follows the same pattern, but it is enqueued on _save_, _touch_, or _destroy_ of any application document. The worker uses the `Search::Admin.for` factory to initialize the correct search model from the affected application document.

The Admin UI inlines `IndexAdminSearch` for the duration of each Admin request so that model changes applied through the Admin UI are applied inline rather than asynchronously.

```ruby
module Workarea
  module Admin
    class ApplicationController < Workarea::ApplicationController
      # ...
      around_action :inline_search_indexing

      # ...

      private

      # ...

      def inline_search_indexing
        Sidekiq::Callbacks.inline(IndexAdminSearch) { yield }
      end

      # ...
    end
  end
end
```

Some callbacks workers delegate to other workers rather than using a search model directly. The workers that are delegated _to_ implement a `.perform` class method, which typically receives the affected Mongoid model instance (rather than an id) as its argument.

For example, changes to catalog variants and product images cause the parent products to be re-indexed into the Storefront indexes. To do so, the `Workarea::IndexProductChildren` worker determines which parent product is affected and uses `IndexProduct.perform` to re-index the product.

```ruby
module Workarea
  class IndexProductChildren
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker

    sidekiq_options(
      enqueue_on: {
        Catalog::Variant => [:save, :destroy],
        Catalog::ProductImage => [:save, :destroy],
        with: -> { [_parent.id.to_s] }
      },
      unique: :until_executing
    )

    def perform(id)
      product = Catalog::Product.find(id) rescue nil
      IndexProduct.perform(product) if product.present?
    end
  end
end
```

Similarly, changes to catalog categories cause affected products to be re-indexed. The `Workarea::IndexCategoryChanges` determines which products are affected and uses `BulkIndexProducts.perform` to re-index them in a single request.

```ruby
module Workarea
  class IndexCategoryChanges
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker

    sidekiq_options(
      enqueue_on: { Catalog::Category => :save, with: -> { [changes] } },
      ignore_if: -> { changes['product_ids'].blank? },
      unique: :until_executing
    )

    def perform(changes)
      if changes['product_ids'].present?
        previous_ids = changes['product_ids'].first || []
        new_ids = changes['product_ids'].second || []

        require_index_ids = (previous_ids - new_ids) + (new_ids - previous_ids)
        BulkIndexProducts.perform(require_index_ids)
      end
    end
  end
end
```

Other indexing workers run on a schedule instead of in response to model changes. Examples are `Workarea::CleanOrders` and `Workarea::KeepProductIndexFresh`.

Finally, some workers are run neither as callbacks nor on a schedule. These workers must be run manually, usually from another worker. Examples are `Workarea::BulkIndexProducts` and `Workarea::BulkIndexSearches`.

### Search Models

Search models are initialized from Mongoid documents and can save and destroy corresponding search documents to and from relevant Elasticsearch indexes. Search documents are responsible for transforming Mongoid documents into search documents, and in the process of doing so, they serialize the entire Mongoid document for storage into Elasticsearch.

#### Initializing

`Workarea::Search::Admin` is an abstract superclass whose subclasses are search models that index documents of type _admin_.

```ruby
puts Workarea::Search::Admin.descendants
# Workarea::Search::Admin::CatalogCategory
# Workarea::Search::Admin::CatalogProduct
# Workarea::Search::Admin::Content
# Workarea::Search::Admin::ContentAsset
# Workarea::Search::Admin::ContentPage
# Workarea::Search::Admin::InventorySku
# Workarea::Search::Admin::Navigation
# Workarea::Search::Admin::NavigationMenu
# Workarea::Search::Admin::Order
# Workarea::Search::Admin::PaymentTransaction
# Workarea::Search::Admin::PricingDiscount
# Workarea::Search::Admin::PricingSku
# Workarea::Search::Admin::Release
# Workarea::Search::Admin::User
```

The factory method `Workarea::Search::Admin.for` will create an instance of one of the above search models for a given Mongoid model (see example in workers section, above).

Similarly, `Workarea::Search::Storefront` is an abstract superclass whose subclasses are search models that index documents of type _storefront_.

```ruby
puts Workarea::Search::Storefront.descendants
# Workarea::Search::Storefront::Category
# Workarea::Search::Storefront::Page
# Workarea::Search::Storefront::Product
# Workarea::Search::Storefront::Search
```

`Workarea::Search::Help` has no descendants and is used as the search model for documents of type _help_.

```ruby
Workarea::Search::Help.descendants
# => []
```

Initialize a search model with an application document (a Mongoid model).

```ruby
product = Workarea::Catalog::Product.create!(name: 'Escape the Room')

product_admin_search_model = Workarea::Search::Admin::CatalogProduct.new(product)

# or use the factory for 'admin' documents
product_admin_search_model = Workarea::Search::Admin.for(product)

product_admin_search_model.class
# => Workarea::Search::Admin::CatalogProduct
```

Search models return a `type`, which describes the Mongoid document type rather than the Elasticsearch document type. In the case of Admin and Storefront search models, many different Mongoid types map to the same Elasticsearch types.

```ruby
# Mongoid "type"
product_admin_search_model.type
# => "product"

# Elasticsearch "type"
product_admin_search_model.class.type
# => :admin
```

The following examples use the same Mongoid model from above to create and explore a Storefront search model.

```ruby
product_storefront_search_model = Workarea::Search::Storefront::Product.new(product)

product_storefront_search_model.class
# => Workarea::Search::Storefront::Product

product_storefront_search_model.type
# => "product"

product_storefront_search_model.class.type
# => :storefront
```

A search model provides access to the original Mongoid model.

```ruby
product_storefront_search_model.model.class
# => Workarea::Catalog::Product

product_storefront_search_model.model.name
# => "Escape the Room"

product_storefront_search_model.model.id
# => "C204935012"
```

Be aware that a search model and its originating Mongoid model have different, albeit similar, IDs.

```ruby
product_storefront_search_model.id
# => "product-C204935012"

product_storefront_search_model.catalog_id
# => "C204935012"

product_storefront_search_model.model.id
# => "C204935012"
```

Since Workarea 3.5, some Storefront search documents are specific to a release.
In these cases, the search model ID also contains the release ID:

```ruby
# create a release
release = Workarea::Release.create!(name: 'Catalog Cleanup')
release.id.to_s
# => "5d8a8ec63e474d3333402efb"

# change the product within that release
Workarea::Release.with_current(release) do
  Workarea::Catalog::Product
    .find(product.id)
    .update_attribute(:name, 'Escape the Room 2')
end

# create a new, release-specific search model for the product
Workarea::Release.with_current(release) do
  product = Workarea::Catalog::Product.find(product.id)
end
product_storefront_search_model = Workarea::Search::Storefront::Product.new(product)

# view the search model ID
product_storefront_search_model.id
# => "product-C204935012-5d8a8ec63e474d3333402efb"
```

#### Saving & Destroying

Use the `save` method to create and index a search document, and use the `destroy` method to delete a search document.

```ruby
product_storefront_search_model.save
```

```ruby
product_storefront_search_model.destroy
```

These operations may affect multiple documents (in multiple indexes) if the application has multiple locales or releases.

#### Creating Search Documents

When search models `save` documents, they must first create a document that is suitable for Elasticsearch. They do so by transforming the Mongoid model, and in many cases, aggregating multiple related models. For example, a searchable product requires catalog, pricing, and inventory data. Each search model implements `as_document` and `as_bulk_document` for this purpose.

The following examples create Admin and Storefront search documents from the same Mongoid source document. Notice how the fields of each search document are different.

```ruby
product_admin_search_model = Workarea::Search::Admin::CatalogProduct.new(product)
product_admin_search_document = product_admin_search_model.as_document
puts JSON.pretty_generate(product_admin_search_document)
# {
#   "id": "product-C204935012",
#   "name": "Escape the Room 2",
#   "facets": {
#     "status": "inactive",
#     "type": "product",
#     "tags": [
# 
#     ],
#     "upcoming_changes": [
#       "5d8a8ec63e474d3333402efb"
#     ],
#     "category": "New",
#     "category_id": [
# 
#     ],
#     "on_sale": false,
#     "inventory_policies": [
# 
#     ],
#     "issues": [
#       "No Images",
#       "No Description",
#       "No Variants"
#     ],
#     "template": "generic"
#   },
#   "created_at": "2019-09-24 21:43:01 UTC",
#   "updated_at": "2019-09-24 21:43:01 UTC",
#   "keywords": [
#     "c204935012"
#   ],
#   "search_text": [
#     "C204935012",
#     "Escape the Room 2",
#     "product"
#   ],
#   "jump_to_text": "Escape the Room 2 (C204935012)",
#   "jump_to_search_text": [
#     "C204935012",
#     "Escape the Room 2",
#     "product"
#   ],
#   "jump_to_position": 3,
#   "jump_to_route_helper": "catalog_product_path",
#   "jump_to_param": "escape-the-room",
#   "releasable": true
# }
```

```ruby
product_storefront_search_model = Workarea::Search::Storefront::Product.new(product)
product_storefront_search_document = product_storefront_search_model.as_document
puts JSON.pretty_generate(product_storefront_search_document)
# {
#   "id": "product-C204935012-5d8a8ec63e474d3333402efb",
#   "type": "product",
#   "slug": "escape-the-room",
#   "active": {
#     "now": false
#   },
#   "release_id": "5d8a8ec63e474d3333402efb",
#   "changeset_release_ids": [
#     "5d8a8ec63e474d3333402efb"
#   ],
#   "suggestion_content": "Escape the Room 2 New, Phone Cases, Gaming, Fiction, Puzzles, Board Games   ",
#   "created_at": "2019-09-24 21:43:01 UTC",
#   "updated_at": "2019-09-24 21:43:01 UTC",
#   "facets": {
#     "category": "New",
#     "category_id": [
# 
#     ],
#     "on_sale": false,
#     "inventory_policies": [
# 
#     ]
#   },
#   "numeric": {
#     "price": [
#       0.0
#     ],
#     "inventory": 0,
#     "variant_count": 0
#   },
#   "keywords": {
#     "catalog_id": "c204935012",
#     "sku": [
# 
#     ],
#     "name": "escape the room 2"
#   },
#   "sorts": {
#     "price": 0.0,
#     "orders_score": 0,
#     "views_score": 0,
#     "inventory_score": 1
#   },
#   "content": {
#     "name": "Escape the Room 2",
#     "category_names": "New, Phone Cases, Gaming, Fiction, Puzzles, Board Games",
#     "description": "",
#     "details": " ",
#     "facets": ""
#   },
#   "cache": {
#     "image": "/product_images/placeholder/small_thumb.jpg?c=1567110494",
#     "pricing": [
# 
#     ],
#     "inventory": [
# 
#     ]
#   }
# }
```

The fields of a search document should match the mapping for its type. Some fields appear in the mapping explicitly, as properties, while other match implicitly, via dynamic templates.

Some fields are used only for storage, not search. For example, the _cache.image_, _cache.pricing_, and _cache.inventory_ fields above are all configured to be stored but not indexed.

```ruby
config.elasticsearch_mappings.storefront = {
  # ...
  storefront: {
    dynamic_templates: [
      # ...
      {
        cache: {
          path_match: 'cache.*',
          mapping: { index: false }
        }
      }
    ],
    properties: {
      # ...
    }
  }
}
```

Cached fields are used when loading results to avoid additional queries to MongoDB.

Much of each search model's implementation is made up of methods used to compose the hash returned from _as\_document_.

#### Transformation "Helpers"

Workarea provides several classes to help construct the `as_document` hash.

`Workarea::Search::Admin::Releasable` is included in search models for releasable models. It includes additional fields in the `as_document` hash related to releases. The following example lists classes that include this module.

```ruby
releasables = Workarea::Search::Admin.descendants.select do |klass|
  klass.included_modules.include?(Workarea::Search::Admin::Releasable)
end
puts releasables.map(&:to_s).sort
# Workarea::Search::Admin::CatalogCategory
# Workarea::Search::Admin::CatalogProduct
# Workarea::Search::Admin::Content
# Workarea::Search::Admin::ContentPage
# Workarea::Search::Admin::NavigationMenu
# Workarea::Search::Admin::PricingDiscount
# Workarea::Search::Admin::PricingSku
```

Several other <abbr title="plain old Ruby object">PORO</abbr>s exist to help construct specific values for the as\_document hash.

- `Workarea::Search::FacetValues`
- `Workarea::Search::HashText`
- `Workarea::Search::OrderText`
- `Workarea::Search::UserText`

### Serialization & De-Serialization

Workarea provides `Workarea::Elasticsearch::Serializer` for serializing in-memory models into strings suitable for storage in Elasticsearch, and for de-serializing those strings back into models without needing to query MongoDB.

```ruby
product = Workarea::Catalog::Product.first

product.class
# => Workarea::Catalog::Product

product.id
# => "006CBBCD90"

product.name
# => "Fantastic Linen Pants"
```

Serialization passes the object through `Mongoid::Document.as_document` (if a Mongoid document), then `Marshal.dump`, and finally `Base64.encode64`.

```ruby
serialized_product = Workarea::Elasticsearch::Serializer.serialize(product)

serialized_product.class
# => Hash

serialized_product['model_class']
# => "Workarea::Catalog::Product"

serialized_product['model']
# => "BAhDOhNCU09OOjpEb2N1bWVudHsVSSIIX2lkBjoGRVRJIg8wMDZDQkJDRDkw...
```

De-serialization reverses the process, passing the string through `Base64.decode64`, then `Marshal.load`, and finally `Mongoid::Factory.from_db` to re-create the Mongoid document instance.

```ruby
deserialized_product = Workarea::Elasticsearch::Serializer.deserialize(serialized_product)

deserialized_product.class
# => Workarea::Catalog::Product

deserialized_product.id
# => "006CBBCD90"

deserialized_product.name
# => "Fantastic Linen Pants"
```

### Rake Tasks

Workarea provides several Rake tasks to manually re-index all search indexes or indexes for particular document types. The tasks are defined in `workarea-core/lib/tasks/search.rake`.

You can run the tasks as commands.

```bash
$ bin/rails workarea:search_index:all
```

```bash
$ bin/rails workarea:search_index:admin
```

```bash
$ bin/rails workarea:search_index:storefront
```

```bash
$ bin/rails workarea:search_index:help
```

Or invoke the tasks programatically.

```ruby
Rake::Task['workarea:search_index:all'].invoke
```

```ruby
Rake::Task['workarea:search_index:admin'].invoke
```

```ruby
Rake::Task['workarea:search_index:storefront'].invoke
```

```ruby
Rake::Task['workarea:search_index:help'].invoke
```

Regardless of how you execute them, these tasks each inline all Sidekiq workers for the duration of the task. As of Workarea 3.3, you can prevent this behavior by setting the environment variable `INLINE` to `false`. For example:

```bash
$ INLINE=false bin/rails workarea:search_index:all
```

### Seeds

Running seeds drops all MongoDB and Elasticsearch data for the current environment and primes both databases with data. Running seeds therefore resets all Elasticsearch indexes.

You can run seeds as a command.

```bash
$ bin/rails db:seed
```

Or programatically.

```ruby
Workarea::Seeds.run
```

## Search Queries

Workarea provides a variety of query classes which are responsible for complicated reads. This includes Elasticsearch searches, for which Workarea provides a variety of search queries.

Search queries are initialized with params and construct and perform an [Elasticsearch request body search](https://www.elastic.co/guide/en/elasticsearch/reference/5.6/search-request-body.html). The query provides access to the raw Elasticsearch response in addition to "loaded" results, which returns the results as Mongoid documents, initialized from the serialized model cache within each Elasticsearch document.

Each search query instance therefore represents the Elasticsearch request and response for a given set of params. UI code often wraps a query instance in a view model and presents the results.

### Types & Initialization

Search queries are classes that include `Workarea::Search::Query`. The following example introspects the Ruby object space for search query classes.

```ruby
searches = ObjectSpace.each_object(Class).select do |klass|
  klass.included_modules.include?(Workarea::Search::Query)
end
puts searches.map(&:to_s).sort
# Workarea::Search::AdminAssets
# Workarea::Search::AdminCategories
# Workarea::Search::AdminDiscounts
# Workarea::Search::AdminInventorySkus
# Workarea::Search::AdminOrders
# Workarea::Search::AdminPages
# Workarea::Search::AdminPaymentTransactions
# Workarea::Search::AdminPricingSkus
# Workarea::Search::AdminProducts
# Workarea::Search::AdminReleasables
# Workarea::Search::AdminSearch
# Workarea::Search::AdminUsers
# Workarea::Search::Categorization
# Workarea::Search::CategoryBrowse
# Workarea::Search::HelpSearch
# Workarea::Search::ProductSearch
# Workarea::Search::RelatedHelp
# Workarea::Search::RelatedProducts
```

Each search query searches for results of a particular Elasticsearch document type. The following example groups the search queries by type.

```ruby
pp searches.group_by(&:document)
# {Workarea::Search::Storefront=>
# [Workarea::Search::RelatedProducts,
# Workarea::Search::ProductSearch,
# Workarea::Search::CategoryBrowse,
# Workarea::Search::Categorization],
# Workarea::Search::Help=>
# [Workarea::Search::RelatedHelp,
# Workarea::Search::HelpSearch],
# Workarea::Search::Admin=>
# [Workarea::Search::AdminUsers,
# Workarea::Search::AdminSearch,
# Workarea::Search::AdminReleasables,
# Workarea::Search::AdminProducts,
# Workarea::Search::AdminPricingSkus,
# Workarea::Search::AdminPaymentTransactions,
# Workarea::Search::AdminPages,
# Workarea::Search::AdminOrders,
# Workarea::Search::AdminInventorySkus,
# Workarea::Search::AdminDiscounts,
# Workarea::Search::AdminCategories,
# Workarea::Search::AdminAssets]}
```

Each search query instance is initialized with params.

```ruby
product_admin_search_query = Workarea::Search::AdminProducts.new(q: 'escape')

product_admin_search_query.class
# => Workarea::Search::AdminProducts

product_admin_search_query.class.document
# => Workarea::Search::Admin

product_admin_search_query.class.document.type
# => :admin
```

### Results

The `#total` and `#stats` methods return meta data about the results.

```ruby
product_admin_search_query.total
# => 1

pp product_admin_search_query.stats
# {"upcoming_changes"=>
# {"doc_count_error_upper_bound"=>0, "sum_other_doc_count"=>0, "buckets"=>[]},
# "template"=>
# {"doc_count_error_upper_bound"=>0,
# "sum_other_doc_count"=>0,
# "buckets"=>[{"key"=>"generic", "doc_count"=>1}]},
# "color"=>
# {"doc_count_error_upper_bound"=>0, "sum_other_doc_count"=>0, "buckets"=>[]},
# "size"=>
# {"doc_count_error_upper_bound"=>0, "sum_other_doc_count"=>0, "buckets"=>[]},
# "price"=>
# {"buckets"=>
# [{"key"=>"*-9.99", "to"=>9.99, "doc_count"=>0},
# {"key"=>"10.0-19.99", "from"=>10.0, "to"=>19.99, "doc_count"=>0},
# {"key"=>"20.0-29.99", "from"=>20.0, "to"=>29.99, "doc_count"=>0},
# {"key"=>"30.0-39.99", "from"=>30.0, "to"=>39.99, "doc_count"=>0},
# {"key"=>"40.0-49.99", "from"=>40.0, "to"=>49.99, "doc_count"=>0},
# {"key"=>"50.0-59.99", "from"=>50.0, "to"=>59.99, "doc_count"=>0},
# {"key"=>"60.0-69.99", "from"=>60.0, "to"=>69.99, "doc_count"=>0},
# {"key"=>"70.0-79.99", "from"=>70.0, "to"=>79.99, "doc_count"=>0},
# {"key"=>"80.0-89.99", "from"=>80.0, "to"=>89.99, "doc_count"=>0},
# {"key"=>"90.0-99.99", "from"=>90.0, "to"=>99.99, "doc_count"=>0},
# {"key"=>"100.0-*", "from"=>100.0, "doc_count"=>0}]},
# "type"=>
# {"doc_count_error_upper_bound"=>0,
# "sum_other_doc_count"=>0,
# "buckets"=>[{"key"=>"product", "doc_count"=>1}]},
# "issues"=>
# {"doc_count_error_upper_bound"=>0,
# "sum_other_doc_count"=>0,
# "buckets"=>
# [{"key"=>"No Description", "doc_count"=>1},
# {"key"=>"No Images", "doc_count"=>1},
# {"key"=>"No Variants", "doc_count"=>1}]},
# "status"=>
# {"doc_count_error_upper_bound"=>0,
# "sum_other_doc_count"=>0,
# "buckets"=>[{"key"=>"inactive", "doc_count"=>1}]},
# "tags"=>
# {"doc_count_error_upper_bound"=>0, "sum_other_doc_count"=>0, "buckets"=>[]}}
```

The `#response` method returns the raw response. Looking at the response, you can see the serialized model data stored within the Elasticsearch document source.

```ruby
pp product_admin_search_query.response
# {"took"=>23,
# "timed_out"=>false,
# "_shards"=>{"total"=>5, "successful"=>5, "failed"=>0},
# "hits"=>
# {"total"=>1,
# "max_score"=>nil,
# "hits"=>
# [{"_index"=>"try_search_development_en_admin",
# "_type"=>"admin",
# "_id"=>"product-273E095F5A",
# "_score"=>6.044283,
# "_source"=>
# {"id"=>"product-273E095F5A",
#
# # ...
#
# "model_class"=>"Workarea::Catalog::Product",
# "model"=>
# "BAhDOhNCU09OOjpEb2N1bWVudHsSSSIIX2lkBjoGRVRJIg8yNzNFMDk1RjVB\n" +
# "BzsGVDobQHVuY29udmVydGFibGVfdG9fYnNvblRJIgl0YWdzBjsGVFsASSIL\n" +
# "YWN0aXZlBjsGVFRJIhhzdWJzY3JpYmVkX3VzZXJfaWRzBjsGVFsASSIMZGV0\n" +
# "YWlscwY7BlRDOwB7BkkiB2VuBjsGVEM7AHsASSIMZmlsdGVycwY7BlRDOwB7\n" +
# "BkkiB2VuBjsGVEM7AHsASSINdGVtcGxhdGUGOwZUSSIMZ2VuZXJpYwY7BlRJ\n" +
# "IhBwdXJjaGFzYWJsZQY7BlRUSSIJbmFtZQY7BlRDOwB7BkkiB2VuBjsGVEki\n" +
# "FEVzY2FwZSB0aGUgUm9vbQY7BlRJIgxkaWdpdGFsBjsGVEZJIglzbHVnBjsG\n" +
# "VEkiFGVzY2FwZS10aGUtcm9vbQY7BlRJIg91cGRhdGVkX2F0BjsGVEl1OglU\n" +
# "aW1lDfJeHcBolXe5BjoJem9uZUkiCFVUQwY7BkZJIg9jcmVhdGVkX2F0BjsG\n" +
# "VEl1OwgN8l4dwGiVd7kGOwlJIghVVEMGOwZG\n"},
# "sort"=>[6.044283, 1503513983497]}]},
# "aggregations"=> # ...}
```

The `#results` method returns the "loaded" results, which de-serializes each result into a Mogoid model. These results are suitable for display in the UI.

```ruby
product_admin_search_query.results.class
# => Workarea::PagedArray

product_admin_search_query.results.to_a.map(&:class)
# => [Workarea::Catalog::Product]

product_admin_search_query.results.first.id
# => "273E095F5A"

product_admin_search_query.results.first.name
# => "Escape the Room"
```

### Product Results

Search queries that return products, such as `ProductSearch`, `CategoryBrowse`, and `RelatedProducts` include the `LoadProductResults` module, which changes the behavior of `results`.

For each result, these queries return a hash of objects rather than a single object.

```ruby
product_search = Workarea::Search::ProductSearch.new(q: 'marble')

product_search.results.class
# => Workarea::PagedArray

product_search.results.to_a.map(&:class)
# => [Hash, Hash, Hash, Hash, Hash, Hash, Hash, Hash, Hash]
```

The following examples show the keys in this hash and the type of each value.

```ruby
product_search.results.first.keys
# => [:id, :catalog_id, :model, :option, :pricing, :inventory]

pp Hash[product_search.results.first.map { |k,v| [k, v.class] }]
# {:id=>String,
# :catalog_id=>String,
# :model=>Workarea::Catalog::Product,
# :option=>NilClass,
# :pricing=>Workarea::Pricing::Collection,
# :inventory=>Workarea::Inventory::Collection}

product_search.results.first[:catalog_id]
# => "29C9ECAAF2"

product_search.results.first[:model].name
# => "Practical Marble Clock"
```

### Composing the Search Request Body

As mentioned above, search queries perform an Elasticsearch request body search. These search requests use a request body constructed from the [Elasticsearch query DSL](https://www.elastic.co/guide/en/elasticsearch/reference/5.6/query-dsl.html).

Search queries provide a Ruby interface for composing these request bodies. The `body` method is responsible for returning a hash which represents the request body. Many other methods are potentially used to compose this final hash. Below is the default implementation of `Workarea::Search::Query#body`.

```ruby
module Workarea
  module Search
    module Query
      # ...

      def body
        {
          query: query,
          post_filter: post_filter,
          aggs: aggregations
        }
        .merge(additional_options)
        .delete_if { |_, v| v.blank? }
      end

      # ...
    end
  end
end
```

Each search query extends or implements the methods necessary to produce the desired request body. As you can see above, the methods `query`, `post_filter`, and `aggregations` contribute directly to the body. The `additional_options` method, calls a method for each search query option included in `Workarea.config.search_query_options`, allowing for configuration of the query builder.

```ruby
Workarea.config.search_query_options
# => ["sort", "size", "from", "suggest"]
```

Many search queries include some of the following modules, which help to build up the desired request body.

- `Workarea::Search::CategorizationFiltering`
- `Workarea::Search::Facets`
- `Workarea::Search::Pagination`
- `Workarea::Search::LoadProductResults`
- `Workarea::Search::ProductDisplayRules`
- `Workarea::Search::QuerySuggestions`
- `Workarea::Search::ProductRules`
- `Workarea::Search::AdminIndexSearch`
- `Workarea::Search::AdminSorting`
