---
title: Analyze Storefront Search Results
excerpt: Use the following tools and techniques to analyze and debug search results in the Storefront.
---

Analyze Storefront Search Results
================================================================================

Use the following tools and techniques to analyze and debug search results in the Storefront.

While the search analysis admin is specific to Storefront searches (i.e. search results pages), the other tools and techniques apply to search results for any of the Storefront search features.
(See [Storefront Search Features](/articles/storefront-search-features.html).)


Search Analysis Admin
--------------------------------------------------------------------------------

Each Storefront search feature uses a search query object to query Elasticsearch for results.
However, the code path to initialize the search query object is different for each Storefront search feature.

Of these features, Storefront searches have the most complicated code path to initialize the search query, and the business logic represented by this code path may not be evident to administrators and developers when searching for products in the Storefront.
(See [Storefront Searches](/articles/storefront-searches.html).)

The _search analysis admin_ is a feature within the Workarea Admin that aims to help developers and technically inclined admins understand specific Storefront searches.
To analyze a search using this feature, you must create a search customization for the specific query you'd like to analyze.
After creating (or finding) the search customization in the Admin, use the _Analyze_ card to navigate to the search analysis admin for the particular query.

The following figures show two examples of the search analysis admin:

![Search analysis admin](/images/search-analysis-admin.png)

![Search analysis admin with alternate rendering section](/images/search-analysis-admin-alternate-rendering.png)

The figures above illustrate the various sections of the search analysis admin, which are described below.

* _Search Analysis_
  * Includes one row for each `ProductSearch` query initialized during the Storefront search request
  * Displays in each row the query string as originally entered, as rewritten by a query rewrite specified on the search customization (if present), and as rewritten by the spelling correction middleware (if applicable)
  * Displays in each row the search middleware which caused this particular `ProductSearch` query to be initialized (if multiple queries)
  * Displays in each row the operator specified in the query's request body, the value of the `:pass` param used to initialize the query object, and the total hits in the response
* _Tokens_
  * Analyzes the query string using the Elasticsearch [Analyze](https://www.elastic.co/guide/en/elasticsearch/reference/5.5/indices-analyze.html) API
  * Includes one row for each token returned by the analyzer, including synonyms
* _Rendering_
  * Displays a UI representing the flow of the search response through the search middleware chain
  * (Refer to the inline help tooltip for the meaning of the icons)
  * (See [Storefront Searches, Creating the Response](/articles/storefront-searches.html#creating-the-response) for an explanation of this flow)
* _Ranking_
  * Lists the top hits from the final search response
  * Indicates results which appear due to being featured (manually administrated)

This feature provides visibility into how the search query object(s) are initialized for a particular Storefront search.
However, you may need greater visibility into the specifics of the request sent to Elasticsearch and the response returned from Elasticsearch.
You may also need to analyze the query or results from one of the other Storefront search features.
For these purposes, you can use an Elasticsearch client.


Elasticsearch Clients
--------------------------------------------------------------------------------

Use an _Elasticsearch client_ to talk directly to your Elasticsearch cluster.
For command line / programmatic access, use the Ruby client, and for web / GUI access, use Kibana.


### Elasticsearch Ruby Client

You can access the Elasticsearch Ruby client from any environment in which you can access a Rails console.
If you need access to a particular environment, open a [support request](http://support.workarea.com).
Within each environment, an Elasticsearch client is already initialized as `Workarea.elasticsearch`:

```ruby
Workarea.elasticsearch.class
# => Elasticsearch::Transport::Client
```

This client provides access to most Elasticsearch APIs.
For details, review the documentation for [Elasticsearch::API (version 5.x)](https://www.rubydoc.info/gems/elasticsearch-api/5.0.5).

Unlike querying Elasticsearch with a search query object, with this client you are responsible for constructing the entire request and knowing which index(es) to search.

The following example lists indexes matching a pattern:

```ruby
puts Workarea.elasticsearch.cat.indices(index: '*storefront', h: ['index'])
# boardgamez_test_en_storefront
# boardgamez_development_en_storefront
```

And the following example searches for all documents in an index and then manipulates the response (views the total hits):

```ruby
Workarea.elasticsearch
  .search(
    index: 'boardgamez_development_en_storefront',
    body: { query: { match_all: {} } }
  )
  .dig('hits', 'total')
# => '141'
```


### Kibana (Web Client)

You can access Kibana, an Elasticsearch GUI, in your web browser.
To install Kibana in a local environment, refer to the [Kibana User Guide (version 5.x)](https://www.elastic.co/guide/en/kibana/5.6/index.html).
Kibana is installed for you in Workarea cloud environments.
If you need access to a particular environment, open a [support request](http://support.workarea.com).

One useful feature in Kibana is the dev tools console, which allows you to construct requests using the Elasticsearch query DSL and view the results:

![Kibana dev tools console](/images/kibana-dev-tools-console.png)

As with the Ruby client, you are responsible for choosing the indexes you'd like to search and analyze.
Kibana allows you to configure index patterns, which identify the indexes to be used for searches and analysis within Kibana:

![Configuring an index pattern in Kibana](/images/configuring-an-index-pattern-in-kibana.png)


Analyzing Queries
--------------------------------------------------------------------------------

When dealing with unexpected or confusing search results, you may want to begin by analyzing the search query object that is responsible for constructing the query (the request body).

To analyze a "real world" query, you may need to insert logging or debugging code into your application to view the state of the query object.
Given the params or ID of a search query object, you can initialize another instance with the same state by calling `.new` or `.find` on the query's class.
The following example uses a simple product search query to demonstrate the relationship and usage of `#params`, `#id`, `.new`, and `.find`:

```ruby
# initialize a search query object with a :q param
search = Workarea::Search::ProductSearch.new(q: 'marble')

# ask for the params; returns a hash of the params
puts search.params
# {"q"=>"marble"}

# ask for the id; returns the params as a JSON string
puts search.id
# {"q":"marble"}

# initialize a second query from the same params
search2 = Workarea::Search::ProductSearch.new(search.params)

# initialize a third query, this time from the original query's id
search3 = Workarea::Search::ProductSearch.find(search.id)

# all 3 queries have the same id (and by extension, the same state)
search.id == search2.id && search2.id == search3.id
# => true
```

Refer to [Storefront Search Features, Initialization & Parameters](/articles/storefront-search-features.html#initialization-amp-parameters) to see the search query class and initialization code path for each Storefront search feature.
From these points in the application you can examine or log attributes of actual search query instances.

After initializing an equivalent search query object, you can inspect it.
Most likely you will want to examine the `#body`, which returns the request body sent to Elasticsearch.

Although the search query's params represent its own state, the state of the request body depends additionally on many external values.
Depending on the search query class these may include the following:

* The current release (if any) and current segments (segments were added in Workarea 3.5)
* Administrable values, accessible to admins and developers
  * Search settings (administration of all searches)
    * Search settings views factor (product popularity multiplier)
    * Search settings boosts (text field boosts)
    * Search settings terms facets
    * Search settings range facets
  * Search customizations & categories (per-search administration)
    * Category terms facets
    * Category range facets
    * Search customization product IDs (featured products)
    * Category product IDs (featured products)
    * Search customization product rules
    * Category product rules
    * Search customization rewrite (query rewrite)
    * Category default sort
* Configurable values, accessible only to developers
  * `Workarea.config.default_search_boosts`
  * `Workarea.config.default_search_facet_result_sizes`
  * `Workarea.config.permitted_facet_params`
  * `Workarea.config.search_dismax_tie_breaker`
  * `Workarea.config.search_facet_default_sort`
  * `Workarea.config.search_facet_dynamic_sorting_size`
  * `Workarea.config.search_facet_result_sizes`
  * `Workarea.config.search_facet_size_sort`
  * `Workarea.config.search_facet_sorts`
  * `Workarea.config.search_name_phrase_match_boost`
  * `Workarea.config.search_query_options`

You may need to examine these values to determine how the request body reached its final state.

If your goal is to modify the request body (for a platform extension), you may want to log the request body and then use it directly within one of the Elasticsearch clients above, particularly the Kibana dev tools console.


Analyzing Indexes & Documents
--------------------------------------------------------------------------------

In addition to analyzing the query sent to Elasticsearch, you may also need to analyze the current state of the indexes and documents.
Search results are created by the intersection of the query's state and the states of the documents being searched.

Typically, complaints of unexpected search results mean either a particular document is matching or not matching (_matching_), or a matching document is sorted unexpectedly (_relevance_).
If the state of the search request is what you are expecting (see section above), then examine the specific documents next.

Use the Elasticsearch clients listed above to examine documents on their own or within the context of a particular query.
For example, the Elasticsearch [Explain](https://www.elastic.co/guide/en/elasticsearch/reference/5.5/search-explain.html) API "computes a score explanation for a query and a specific document."

Be aware that a particular search document may be missing or stale due to changes in MongoDB that have not yet migrated to Elasticsearch.
Search indexing jobs may be pending in your Sidekiq queue, or there may be an issue with automated search indexing in your environment (See [Search, Indexing](/articles/searching.html#indexing)).
To resolve an issue, you may need to manually re-index all documents or specific documents (See [Index Storefront Search Documents](/articles/index-storefront-search-documents.html)).

Finally, if your search documents are up to date but do not contain the correct fields, field mappings, or field values, review the logic of your search models.
For example, you may have added a new field to the Mongoid model but it is absent in the corresponding search model, or mapped incorrectly.
See [Storefront Search Features, Search Models](/articles/storefront-search-features.html#search-models) for coverage of search models, including dynamic mapping.

You may need to verify the field mappings for the `'storefront'` Elasticsearch type used for Storefront Elasticsearch documents.
To do so, use the Elasticsearch _Get Mapping_ API, which is demonstrated below:

```ruby
puts JSON.pretty_generate(
  Workarea.elasticsearch.indices
    .get_mapping(type: 'storefront')
    .dig(
      'boardgamez_development_en_storefront',
      'mappings',
      'storefront',
      'properties'
    )
)
# {
#   "active": {
#     "properties": {
#       "now": {
#         "type": "boolean"
#       }
#     }
#   },
#   "cache": { ... },
#   "content": {
#     "properties": {
#       "category_names": {
#         "type": "text",
#         "analyzer": "text_analyzer"
#       },
#       "description": { ... },
#       "details": { ... },
#       "facets": { ... },
#       "name": { ... }
#     }
#   },
# ...
``` 


Storefront Caching
--------------------------------------------------------------------------------

As a final concern, be aware of caching within the Storefront.
In environments where caching is enabled, the entire HTTP response may be cached, or fragments of the response may be cached.
(See [HTTP Caching](/articles/http-caching.html) and [HTML Fragment Caching](/articles/html-fragment-caching.html).)

All Storefront search features except for autocomplete (which is an async/XHR feature) may be affected by both types of caching.
