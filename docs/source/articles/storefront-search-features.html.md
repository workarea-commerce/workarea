---
title: Storefront Search Features
excerpt: Workarea Storefront has several features that rely on Elasticsearch. This document describes those features and aspects of their shared architecture/implementation.
---

Storefront Search Features
================================================================================

Workarea Storefront has several features that rely on Elasticsearch.
This document describes those features and aspects of their shared architecture/implementation.


Summary of Features
--------------------------------------------------------------------------------

### Searches

The most obvious of the features are _searches_ (i.e. search results pages).
Storefront searches match products to queries entered by shoppers.
These queries are built via a user interface and include a query string and optionally additional parameters such as filters, a sort, and a page.

![Storefront search](/images/storefront-search.png)

Admins can customize the results of all searches via _search settings_ (terms facets, range facets, field boosts, product popularity multiplier), and they can customize specific searches via _search customizations_ (featured products, product rules, query rewrite).


### Categories

Less evidently, _categories_ (i.e. category pages) in the Storefront are also a search feature.
Category pages and search results pages share a similar UI containing product results, filters, sorts, and pagination.
This UI is known as the _product browsing_ interface.

![Storefront category](/images/storefront-category.png)

A category differs from a search in that the query is determined primarily by the retailer (via administrators and developers), although shoppers may filter, sort, and paginate the results.
Admins define the category logic by setting featured products and product rules for each category, similar to the administration for a search customization.
Admins can also set terms facets, range facets, and default sort for each category.


### Category Summary Content Blocks

_Category summary content blocks_ are [content blocks](/articles/content.html#block) which display the first _n_ product results for a given category.

![Storefront category summary content block](/images/storefront-category-summary-content-block.png)

These blocks use the same search query as a full category page. Admins can therefore manage the results for these blocks through the admin for the particular category.


### Product Recommendations

The final search feature in the Storefront is _product recommendations_.
Products are recommended to shoppers in various contexts throughout the Storefront, such as:

* Product detail pages
* Cart pages
* Checkout confirmation pages
* Emails
* User account pages
* Personalized recommendations content blocks

The following figure shows recommendations on a product detail page:

![Storefront category summary content block](/images/storefront-product-recommendations.png)

The recommendations subsystem uses a variety of recommendations _sources_ when determining which products to recommend.
One of these sources, _similar products_, uses an Elasticsearch query to determine the results.

This query shares _product display rules_ with the queries used for searches and categories.
Extending any of these features therefore requires an understanding of their shared architecture and implementation, which is covered at a high level in the sections that follow.


Querying
--------------------------------------------------------------------------------

In each of the features above, shoppers are requesting pages which contain search results.
Application code responsible for handling these _Storefront requests_ must make additional _search requests_ to Elasticsearch.
Elasticsearch responds to these requests, and the application processes the results, allowing it to respond to the original Storefront requests.

The following figure illustrates this process:

![Storefront requests and search requests](/images/storefront-requests-and-search-requests.png)

Furthermore, the following table provides specific examples of Storefront requests and their corresponding search requests.

Storefront Request                            | Search Request
--------------------------------------------- | ------------------------------------------------------
Search results page                           | Products matching the user's query
Home page with category summary content block | First _n_ products matching the category
Order confirmation email with recommendations | Products similar to those in the user's order


### Search Query Objects

Notice in the figure above that the "application code" (the specific code varies by search feature) uses a _search query object_ to encapsulate the search request and response to/from Elasticsearch.
A search query object is an instance of a query class (found throughout Workarea engines in _/app/queries_) that implements the `Search::Query` interface.
There are several search query classes, each of which encapsulates the logic for a particular _type_ of query, such as a product search, a category, search as you type results, or similar products for recommendations.
Each search query object is an instance of one of these classes, initialized with specific parameters to create a specific search query.
(Refer to the table in the following section for a mapping of search features to their corresponding search query classes.)

A search query object is responsible for sending the request to Elasticsearch and caching the response.
The query object also processes the response into a set of results, which are Mongoid model instances, avoiding the need to additionally query MongoDB to display results.


### Initialization & Parameters

A search query object is a short-lived, in-memory Ruby object (e.g. not persisted or tied to a database document).
It is initialized by other application code as needed, to get results from Elasticsearch.

The following table maps each search feature to its corresponding search query class, as well as the application code responsible for initializing instances of this class (potential callers).

Search Feature                                 | Search Query Class          | Potential Callers
---------------------------------------------- | --------------------------- | ---------------------------------------------------------------------------------------------------
Searches                                       | `Search::ProductSearch`     | See [Storefront Searches](/articles/storefront-searches.html)
Categories and category summary content blocks | `Search::CategoryBrowse`    | `Storefront::CategoryViewModel#search_query`
Product recommendations                        | `Search::RelatedProducts`   | `Recommendations::ProductBased`, `Recommendations::OrderBased`, `Recommendations::UserActivityBased`

A search query object is initialized with parameters that specify the details of the particular query.
For example, the following queries represent product searches for the terms `'granite'` and `'marble'`, respectively:

```ruby
Workarea::Search::ProductSearch.new(q: 'granite')
Workarea::Search::ProductSearch.new(q: 'marble')
```

In practice, the initialization params contain additional data, such as filters, sort, page, available terms facets, and available range facets.

Once initialized, a search query object provides an interface that can be subdivided into two primary concerns: constructing the search request body and returning search results.
Let's look at the results first.


### Results

The search query interface has several "results" methods, which cause the app to send a request to Elasticsearch and cache the response within the search query object.
These methods include `#results`, `#response`, and `#total`.

The primary API call, `#results`, returns a collection of results, where each one (in the case of product results) provides the following:

* The ID of the Elasticsearch document (`:id`)
* The ID of the corresponding MongoDB document (`:catalog_id`)
* Mongoid model instances (`:model`, `:pricing`, and `:inventory`; each cached directly in Elasticsearch)
* The raw "hit" from Elasticsearch (`:raw`)

The following example creates a search query and examines the first result:

```ruby
search = Workarea::Search::ProductSearch.new(q: 'marble')
result = search.results.first

result.keys
# => [:id, :catalog_id, :model, :option, :pricing, :inventory, :raw]

result[:id]
# => "product-F6344784CF"
result[:catalog_id]
# => "F6344784CF"

result[:model].class
# => Workarea::Catalog::Product
result[:model].name
# => "Incredible Marble Bench"

result[:pricing].class
# => Workarea::Pricing::Collection
result[:inventory].class
# => Workarea::Inventory::Collection
```

This data provides everything you need to present or process the results as needed.
The following table illustrates how the various Storefront search features use the search results:

Storefront Feature                                    | Use of Search Results
----------------------------------------------------- | ------------------------------------------------------
Searches, categories, category summary content blocks | Init a `Storefront::ProductViewModel` from the cached product, pricing, and inventory models stored within each search result; display the results
Product Recommendations                               | Pluck the MongoDB IDs from the results, and return the collection of IDs to the recommendations subsystem

The table above hints at uses of search results that go beyond simply displaying results.
Consider this when designing features for your own applications and plugins (e.g. using search results to construct a product feed).


### Requests

The remaining portion of the search query interface is dedicated to constructing the body of the search request.
The request body follows the format of the [Elasticsearch Query DSL](https://www.elastic.co/guide/en/elasticsearch/reference/5.6/query-dsl.html).

The `#body` method of the search query interface returns the complete request body:

```ruby
search = Workarea::Search::ProductSearch.new(q: 'marble')
request_body = search.body
puts JSON.pretty_generate(request_body)
#{
#  "query": {
#    "bool": {
#      "must": [
#        {
#          "term": {
#            "type": "product"
#          } 
#        },
#        {
#          "range": {
#            "numeric.variant_count": {
#              "gt": 0
#            } 
#          } 
#        },
#...
```

The format of the above example should look familiar if you've used Elasticsearch.

Other methods of the search query interface represent subsections of the request body.
These methods include:

* `#query`
* `#post_filter`
* `#aggregations`
* `#sort`
* `#size`
* `#from`
* `#suggest`

These methods are used to implement `#body`, but they are also useful to examine on their own.
The following example examines the sort clauses of the request body.

```ruby
search = Workarea::Search::ProductSearch.new(q: 'marble')
sort_dsl = search.sort
puts JSON.pretty_generate(sort_dsl)
#[
#  {
#    "sorts.marbl": {
#      "order": "asc",
#      "missing": "_last",
#      "unmapped_type": "float"
#    }
#  },
#  {
#    "sorts.inventory_score": {
#      "order": "desc",
#      "missing": "_first",
#      "unmapped_type": "float"
#    }
#  },
#  {
#    "_score": "desc"
#  },
#  {
#    "sorts.orders_score": {
#      "order": "desc",
#      "missing": "_last",
#      "unmapped_type": "float"
#    }
#  }
#]
```

If you need to extend a search query, you can extend only the relevant portion of the request body by decorating the appropriate method of the search query interface.

Be aware that each request body is very stateful. It depends on various values, such as:

* The class of the query object
* The parameters with which the query object was initialized
* Various administrative values accessible to admins (e.g. search settings, search customizations, categories)
* Various configuration values accessible to developers

For more details, see [Analyze Storefront Searches, Analyzing Queries](/articles/analyze-storefront-search-results.html#analyzing-queries).

The request body is sent to Elasticsearch when any of the "results" methods (see above) are called on the search query object.
The results depend on the state of the request body _and_ the state of the indexes and documents being searched.
The following sections therefore examine indexes and documents.


Indexing
--------------------------------------------------------------------------------

An Elasticsearch cluster has many indexes, only some of which are searched by the Storefront search features.
Each search query class searches a specific search index.

The following example finds the index for a particular query:

```ruby
search = Workarea::Search::ProductSearch.new(q: 'marble')
search.class.document.current_index.name
# => "boardgamez_development_en_storefront"
search.class.document.current_index.url
# => "http://localhost:9200/boardgamez_development_en_storefront"
```

Furthermore, this index varies by Rails environment, site name, and locale.
Therefore, changing one of these values (e.g. Rails environment), changes the index to search:

```ruby
Rails.env = 'test'
search.class.document.current_index.name
# => "boardgamez_test_en_storefront"
```

Storefront indexes contain documents of multiple Elasticsearch types.
However, the search query classes described above search only those documents of type `'storefront'`.

Since these documents are all of the same Elasticsearch type, they all share the same field mapping (i.e. schema).
The fields within each of these search documents were derived from data in one or more MongoDB documents at the time the search document was indexed.


### Search Models

_Search models_ are objects used to index documents into Elasticsearch.
They create search documents from MongoDB documents and put the search documents into the appropriate search indexes (i.e. send indexing requests to Elasticsearch).

There are different search model classes to handle the creation and indexing of documents of various types.
The following table maps each search result type to its corresponding Mongoid model class and Storefront search model class.

Search Result | Mongoid Model         | Search Model
------------- | --------------------- | ----------------------------
Product       | Catalog::Product      | Search::Storefront::Product
Category      | Catalog::Category     | Search::Storefront::Category
Page          | Content::Page         | Search::Storefront::Page
Search        | Metrics::SearchByWeek | Search::Storefront::Search

The search documents produced by these search models each have a `:type` field, which indicates its type, such as `'product'` or `'category'`.
Don't confuse this with the Elasticsearch type, which is stored in the `:_type` field (and is always `'storefront'` for the search models discussed here).

(Also, if you are looking directly at an index--in Kibana for example--be aware there is an additional Elasticsearch `:_type` of `'category'`.
Don't confuse this with a `:type` of `'category'`.)


### Initialization

Like search query objects, Storefront search models are short-lived, in-memory Ruby objects.
They are created as needed to create and index the search documents which will represent a corresponding MongoDB document within Storefront Elasticsearch indexes.

A Storefront search model is therefore initialized with a Mongoid model:

```ruby
catalog_category = Workarea::Catalog::Category.first
storefront_search_category = Search::Storefront::Category.new(catalog_category)
```

The methods `#as_document` and `#save` are the primary public interface of a search model.
The `#as_document` method creates the search document, while the `#save` method indexes it.


### Creating Search Documents

The following examples show the fields of a catalog category document from MongoDB and the corresponding search document created by the Storefront category search model.
A category search model is fairly simple; compare the examples to see the transformation from Mongoid model to search document (using `Search::Storefront::Category#as_document`).

```ruby
catalog_category = Workarea::Catalog::Category.first
puts JSON.pretty_generate(catalog_category.as_document)
#{
#  "_id": "5cb23a5857c22f5403ddf8b6",
#  "tags": [],
#  "active": {
#    "en": true
#  },
#  "subscribed_user_ids": [],
#  "product_ids": [],
#  "show_navigation": true,
#  "default_sort": "top_sellers",
#  "terms_facets": [],
#  "range_facets": {},
#  "name": {
#    "en": "Electronics & Computers"
#  },
#  "slug": "electronics-computers",
#  "updated_at": "2019-04-13 19:36:59 UTC",
#  "created_at": "2019-04-13 19:36:56 UTC",
#  "product_rules": [
#    {
#      "_id": "5cb23a5857c22f5403ddf8b7",
#      "name": {
#        "en": "search"
#      },
#      "operator": "equals",
#      "value": {
#        "en": "*"
#      }
#    }
#  ]
#}
```

```ruby
storefront_search_category =
  Workarea::Search::Storefront::Category.new(catalog_category)
puts JSON.pretty_generate(storefront_search_category.as_document)
#{
#  "id": "category-5cb23a5857c22f5403ddf8b6",
#  "type": "category",
#  "slug": "electronics-computers",
#  "active": {
#    "now": true
#  },
#  "suggestion_content": null,
#  "created_at": "2019-04-13 19:36:56 UTC",
#  "updated_at": "2019-04-13 19:36:59 UTC",
#  "facets": {},
#  "numeric": {},
#  "keywords": {},
#  "sorts": {},
#  "content": {
#    "name": "Electronics & Computers"
#  },
#  "cache": {}
#}
```

Most of the methods on a search model are essentially "private" methods used to compose the implementation of `#as_document`.
As shown below, the Storefront category search model implements `#content`, `#slug`, and `#active`.
(This search model inherits its implementation of `#as_document` and the other methods that compose it, which is why you don't see them defined below.)

```ruby
module Workarea
  module Search
    class Storefront
      class Category < Storefront
        def content
          { name: model.name }
        end

        def slug
          model.slug
        end

        def active
          { now: model.active? }
        end
      end
    end
  end
end
```

Compare the search model method implementations to the resulting search document shown further above.
Notice how each method represents a subsection of the overall document.
When extending a search model, you can decorate only the methods that define the fields you want to affect within the resulting search document.


### Field Namespaces

Also notice the nesting of fields that is apparent in both the search model class definition and the resulting search document.
In the examples above, `name` is nested within `content`, and `now` is nested within `active`.

These are examples of _namespaced fields_.

Although they appear as nested fields within the JSON search document, Elasticsearch actually flattens them to `content.name` and `active.now`.
You will see the fields referenced this way within Elasticsearch request bodies and when viewing fields within Kibana.

The namespaces (e.g. `active` and `content`) perform two primary functions.
The `active` namespace is a special case which groups fields representing the activeness of products.
These fields allows for more accurate previewing of releases in the Storefront (inactive products are excluded from results).
Before Workarea 3.5, these fields keyed off of releases (storing a per-release active value).
Beginning in Workarea 3.5, separate documents track changes across releases, so the only field in the `active` namespace is `active.now`.

All other namespaces exist primarily to perform dynamic field mapping.
For example, all fields within the `content.*` namespace are mapped within Elasticsearch as _text_, while all fields in the `keywords.*` namespace are mapped as _keywords_.
See [Change Storefront Search Results](/articles/change-storefront-search-results.html) to learn how to take advantage of this feature when adding fields to a search model.


### Product Search Documents

Most Storefront search documents are _product_ documents, which are considerably more complex than the category document used as the example above.
The following example, which is a (truncated) product search document will help to illustrate a few additional points about search documents and models.

```ruby
catalog_product = Workarea::Catalog::Product.first
storefront_search_product =
  Workarea::Search::Storefront::Product.new(catalog_product)
puts JSON.pretty_generate(storefront_search_product.as_document)
#{
#  "id": "product-027C3B5604",
#  "type": "product",
#  "slug": "awesome-iron-shoes",
#  "active": {
#    "now": true
#  },
#  "facets": {
#    ...
#    "category": "Movies",
#    "on_sale": false,
#    "inventory_policies": [
#      "standard",
#      ...
#    ]
#  },
#  "numeric": {
#    "price": [
#      75.99,
#      ...
#    ],
#    "inventory": 26,
#    "variant_count": 3
#  },
#  ...
#  "content": {
#    "name": "Awesome Iron Shoes",
#    "category_names": "Electronics & Computers, Beauty ...",
#    "description": "marfa yuccie asymmetrical knausgaard chartreuse ...",
#    "details": "216321732-9 Size: Large; Color: Violet ...",
#    "facets": "Size: Large, Extra Small; Color: Violet, Magenta, Sky Blue"
#  },
#  "cache": {
#    "image": "/product_images/placeholder/small_thumb.jpg?c=1555184216",
#    "pricing": [
#      {
#        "model_class": "Workarea::Pricing::Sku",
#        "model": "25c2FsQy..."
#      },
#      ...
#    ],
#    "inventory": [
#      {
#        "model_class": "Workarea::Inventory::Sku",
#        "model": "25c2FsQy..."
#      },
#      ...
#    ]
#  }
#}
```

The product search document above contains many more fields than the previously shown category search document (the document above is heavily truncated--the entire document is a bit overwhelming).
Notice the use of namespaces to group most fields by their mapping (i.e. data type).

The `cache.*` namespace is new in this example. This namespace is used for fields that are stored but not indexed (i.e. not searched).
The `"model"` fields in this namespace actually contain serialized Mongoid models, allowing these models to be fetched directly from Elasticsearch, and preventing the need to additionally query MongoDB to display search results.

Also notice that these cached fields and many other fields in this document contain data that is derived from the pricing SKU and inventory SKU models associated with this catalog product model.
Search models are similar to view models in that they are initialized from a model, but they may cross bounded contexts to look up additional models as necessary to create a "view" of the original model that is suitable for a specific context (in this case, a Storefront search index).

( Since Workarea 3.5, search documents are affected by the current release. See [Search, Search Models](/articles/searching.html#search-models) for an example of this. )

Now that you've seen how search documents are created and how they are structured, let's look at how they are actually indexed into Elasticsearch.


### Indexing

While `#as_document` is responsible for creating the search document, `#save` is the search model API call that actually puts the document into Elasticsearch.

For example, the following creates and indexes a Storefront category search document from a catalog category:

```ruby
catalog_category = Workarea::Catalog::Category.first
Search::Storefront::Category.new(catalog_category).save
```

The `#save` call uses `#as_document` to create the document, but it also adds an additional field, `:model`, which contains a serialized instance of the original Mongoid model.
(This is similar to the pricing and inventory examples in the above section, but this field serializes the primary model from which the search document was initialized).
It then indexes the document into the appropriate Storefront search index, which depends on the Rails environment, site name, and locale.
If the application has multiple locales, the `#save` call repeats this process for each locale, ensuring the original model is represented by separate search documents in separate indexes.

While `#save` is the primary "public" API of a search model, you rarely need to call it as a developer.
This is in part because most search indexing is automatic or is manual indexing of the "index everything" variety.
(See  [Search, Indexing](/articles/searching.html#indexing).)

When you _do_ need to index a specific document or documents, they are usually _product_ documents, and there are specific APIs you must go through to index products.
(See  [Index Storefront Search Documents](/articles/index-storefront-search-documents.html).)
