---
title: Index Storefront Search Documents
excerpt: This document provides procedures developers can use to manually index Storefront search documents.
---

Index Storefront Search Documents
================================================================================

This document provides procedures developers can use to manually index Storefront search documents.

These procedures are for _manually_ indexing search documents. However, most search indexing is _automatic_, as explained in [Search, Indexing](/articles/searching.html#indexing).
See also [Storefront Search Features, Indexing](/articles/storefront-search-features.html#indexing) for an overview of Storefront search document creation and indexing.


Index All Storefront Search Documents
--------------------------------------------------------------------------------

Workarea's `search.rake` Rakefile provides a task for (re)indexing all Storefront search documents.

Index all Storefront search documents from a shell session within the environment:

```bash
$ bin/rails workarea:search_index:storefront
```

Index all Storefront search documents within Ruby:

```ruby
Rake::Task['workarea:search_index:storefront'].invoke
```

The procedures above index documents _inline_ (i.e. in the foreground).
Alternatively, set the environment variable `INLINE` to `false` before executing the task to perform the indexing with Sidekiq workers (i.e. in the background):

```bash
$ INLINE=false bin/rails workarea:search_index:all
```


Index Specific Storefront Search Documents
--------------------------------------------------------------------------------

In some cases, you may need to index only specific Storefront search documents.
The procedure for this varies for product and non-product search documents.


### Non-Product Documents

For non-product search documents (e.g. categories, pages, searches), initialize a Storefront search model and call `#save` to index the resulting search document.

```ruby
catalog_category = Workarea::Catalog::Category.first
Search::Storefront::Category.new(catalog_category).save
```

See [Storefront Search Features, Search Models](/articles/storefront-search-features.html#search-models) for an explanation of Storefront search models.


### Product Documents

For product search documents, don't use a search model directly.
Use any of the following API calls, which create the search model instances for you.
(See [Workers](workers.html) for more details regarding the `perform` and `perform_async` methods.)

* `Workarea::IndexProduct.perform(product)`
* `Workarea::IndexProduct#perform(id)`
* `Workarea::IndexProduct#perform_async(id)`
* `Workarea::BulkIndexProducts.perform_by_models(products)`
* `Workarea::BulkIndexProducts.perform(ids)`
* `Workarea::BulkIndexProducts#perform(ids)`
* `Workarea::BulkIndexProducts#perform_async(ids)`

For example, index one product:

```ruby
catalog_product = Workarea::Catalog::Product.first
Workarea::IndexProduct.perform(catalog_product)
```

Or, enqueue a background job to index 5 products in bulk (using only a single request to Elasticsearch):

```ruby
catalog_product_ids = Workarea::Catalog::Product.all.pluck('id').first(5)
# => ["71C098FFD9", "9A7160EBF0", "2702316B04", "06C6FC0827", "0FA514641B"]
Workarea::BulkIndexProducts.new.perform_async(catalog_product_ids)
```

Each of the API calls above provides two additional functions, which is why these calls are used instead of creating search models directly.

First, calling any of the above methods sets `:last_indexed_at` on each of the affected models in MongoDB.
Among other things, this timestamp is used by workers responsible for keeping indexes fresh.

Second, for each product passed in, these methods create a collection of _product entries_ to represent the document within the Storefront search indexes.
The product entries collection (an instance of `Search::ProductEntries` is a collection of search models, each of which produce a search document to be indexed.

This allows more or fewer search documents to be indexed for each product.
For example, with [Workarea Browse Option](https://github.com/workarea-commerce/workarea-browse-option) installed, a single MongoDB document may be represented by multiple search documents in each search index (e.g. one for each color of the product).
In contrast, with [Workarea Package Products](https://github.com/workarea-commerce/workarea-package-products) installed, the child products of a package are not indexed at all (they produce an empty product entries collection).

Furthermore, since Workarea 3.5, a product may have release-specific search documents, so an index may contain multiple documents for a product: one for the "live" representation and others used when previewing specific upcoming releases.

The product entries abstraction also allows a different search model to be used conditionally.
For example, Workarea Browse Option extends product entries to use a different search model for those products that "browse by option".
This search model uses only variants of the given option (e.g. blue) to construct the search model.
Similarly, Workarea Package Products uses a different search model for "package" products.
This search model includes details from the package's "child" products, which themselves are not indexed.
