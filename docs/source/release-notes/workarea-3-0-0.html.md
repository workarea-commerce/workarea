---
title: Workarea 3.0.0
excerpt: Workarea 3 renames the WebLinc software and its components to Workarea. The rename encompasses the core software and all plugins, including file and directory names, code constants, repository names, and gem names.
---

# Workarea 3.0.0

## Rename to Workarea

Workarea 3 renames the <cite>WebLinc</cite> software and its components to <cite>Workarea</cite>. The rename encompasses the core software and all plugins, including file and directory names, code constants, repository names, and gem names.

## Dependencies

### Elasticsearch

Workarea 3 requires [Elasticsearch](https://www.elastic.co/products/elasticsearch) [version 5.x](https://www.elastic.co/guide/en/elasticsearch/reference/current/breaking-changes-5.0.html). You must update this dependency in all environments.

### Ruby

Workarea 3 requires [Ruby](https://www.ruby-lang.org/en/) [version 2.3.x](https://www.ruby-lang.org/en/news/2015/12/25/ruby-2-3-0-released/). You must update this dependency in all environments.

### PhantomJS

Workarea 3 requires [PhantomJS](http://phantomjs.org/) [version 2.x](http://phantomjs.org/release-2.0.html). You must update this dependency in all test environments. Workarea 2.3.0 allowed use of PhantomJS 2.x, but this version is now a hard requirement in Workarea version 3.

## Extracted Plugins

Workarea v3 removes the following features.

- Product sharing
- Browsing by option (for example, a separate search result for each color of a product)
- Content search results
- Developer toolbar
- Product quickview

The features above have been extracted to the plugins below. These plugins are maintained by the WebLinc Product Team.

- [Workarea Share](https://stash.tools.weblinc.com/projects/WL/repos/workarea-share/browse)
- [Workarea Browse Option](https://stash.tools.weblinc.com/projects/WL/repos/workarea-browse-option/browse)
- [Workarea Content Search](https://stash.tools.weblinc.com/projects/WL/repos/workarea-content-search/browse)
- [Workarea Developer Toolbar](https://stash.tools.weblinc.com/projects/WL/repos/workarea-developer-toolbar/browse)
- [WebLinc Product Quickview](https://stash.tools.weblinc.com/projects/WL/repos/weblinc-product-quickview/browse)

## Testing

First introduced in WebLinc 2.3, <cite>Minitest</cite> is the standard test framework in Workarea 3.0. Using Minitest allows applications to run Workarea platform tests without copying them into the application, and it allows applications to decorate tests like other Ruby classes.

Workarea version 3 provides the following commands to run tests within an application.

- `bin/rails workarea:test:core` to run tests from <cite>workarea-core</cite> (with decorators)
- `bin/rails workarea:test:admin` to run tests from <cite>workarea-admin</cite> (with decorators)
- `bin/rails workarea:test:storefront` to run tests from <cite>workarea-storefront</cite> (with decorators)
- `bin/rails workarea:test` to run tests from <cite>workarea-core</cite>, <cite>workarea-admin</cite>, and <cite>workarea-storefront</cite> (with decorators)
- `bin/rails workarea:test:decorated` to run decorated tests only

Workarea 3 moves all _feature_ and _request_ tests from RSpec to Minitest (and renames them _system_ and _integration_ tests, respectively) and also moves a variety of other tests from RSpec to Minitest. Other tests remain in RSpec, however, these tests will be moved to Minitest in future minor releases.

Workarea 3 moves all RSpec dependencies into a separate [Workarea RSpec](https://stash.tools.weblinc.com/projects/WL/repos/workarea-rspec/browse) engine. This engine will provide continued support for RSpec testing during and after the migration of platform tests from RSpec to Minitest.

**Existing applications are not expected to migrate existing specs to Minitest. RSpec testing will continue to be supported indefinitely.** However, new applications should write Minitest tests exclusively, in order to benefit from test decoration.

Refer to [Testing Concepts](/articles/testing-concepts.html) for further coverage of testing in Workarea 3.

## Workers, Listeners & Publishers

Workarea version 3 removes WebLinc's system of listeners and publishers and adds Sidekiq extensions that provide the concept of a _callbacks worker_ in addition to other changes to the workers APIs.

The [Workers](/articles/workers.html) guide explains the version 3 workers APIs.

## Search

Workarea 3 makes a variety of changes to search, including those in the following list. The [Search](/articles/searching.html) guide explains the version 3 search APIs in greater detail.

- The `Elasticsearch::Persistence` library is removed in favor of using the Elasticsearch Ruby API directly
- `Weblinc::Search::Repository` and `Weblinc::Search::Mapper` are removed in favor of lighter abstractions
- `Elasticsearch::Document` and `Elasticsearch::Index` provide abstractions that more closely mimic the <abbr title="object document mapper">ODM</abbr> abstractions used for MongoDB
- The `Workarea::Search::Query` module and the construction of Elasticsearch searches has been redesigned to leverage developers' knowledge of Ruby modules and code re-use
- The list of indexes used is changed to reduce the number of Elasticsearch queries and to provide greater flexibility (for example, a single index is used to search for searches, products, categories, and pages in the storefront)
- Elasticsearch mappings are stored as configuration in `Workarea.config.elasticsearch_mappings`
- Personalized search is removed, and all search results pages are cached by URL
- Learning search is simplified and leverages data stored for analytics

## Shipping

Workarea v3 makes a variety of changes to shipping. Specifically, shipping rates are requested from an [ActiveShipping](http://www.rubydoc.info/gems/active_shipping/1.8.6) carrier, and Workarea provides a default carrier that mimics the previous shipping implementation. This change allows for easier extension of shipping functionality.

The [Shipping](/articles/shipping.html) guide explains the version 3 shipping APIs in more detail.

## Navigation

Workarea version 3 splits navigation into two separate concerns: taxonomy and navigation. <dfn>Taxons</dfn>, which compose the site's taxonomy, are used to organize [Navigables](/articles/navigable.html) and other nodes into a tree structure. This structure provides the hierarchy needed for secondary navigation such as breadcrumbs.

Meanwhile, the primary navigation is presented as a series of <dfn>menus</dfn>, each of which is [contentable](/articles/contentable.html) and [releasable](/articles/releasable.html), allowing for more flexible visual designs and management.

The [Navigation](/articles/navigation.html) guide explains the APIs concerning taxonomy and navigation.

## Content

Workarea version 3 iterates on <abbr title="content management system">CMS</abbr> functionality, primarily to allow faster creation of custom content block types. Block types are stored in memory and are created using a <abbr title="domain specific language">DSL</abbr>. Developers no longer need to implement the admin <abbr title="user interface">UI</abbr> for each block type. A block type is composed of <dfn>fields</dfn>, which are organized into <dfn>fieldsets</dfn>. A field defines the type of UI control that should be used to collect data, the default value of the field, and how the collected data should be typecast.

The [Content](/articles/content.html) guide explains the content APIs in more detail.

## Sample Data (Seeds)

Workarea 3 renames `Weblinc::SampleData` to `Workarea::Seeds` and removes the `weblinc:sample_data` Rake task in favor of Rails' own `db:seed` task. New Workarea 3 applications implement `db:seed` as follows:

```
# your_app/db/seeds.rb
require 'workarea/seeds'
Workarea::Seeds.run
```

Applications migrating to version 3 may want to copy this implementation.

Seed files live in the Rails `app` directory and are therefore required automatically and may be decorated like other Ruby classes. Furthermore, Workarea 3 stores the list of seeds to be run in the `Workarea.config.seeds` configuration to allow for easier extension.

## CSS Grid System

Workarea v3 uses the [Avalanche CSS grid system](http://colourgarden.net/avalanche/) ([source](https://github.com/colourgarden/avalanche)) for generic grid layout in the Admin and Storefront <abbr title="user interfaces">UIs</abbr>.

This grid system has configurable <dfn>settings</dfn>, which are configured differently for the [admin](https://stash.tools.weblinc.com/projects/WL/repos/workarea/browse/admin/app/assets/stylesheets/workarea/admin/settings/_grid.scss?at=refs%2Ftags%2Fv3.0.0) and [storefront](https://stash.tools.weblinc.com/projects/WL/repos/workarea/browse/storefront/app/assets/stylesheets/workarea/storefront/settings/_grid.scss?at=refs%2Ftags%2Fv3.0.0).

## Admin UI

Workarea version 3 redesigns the Admin UI, providing improved performance, discoverability, and extensibility. Some of the specific changes are summarized in the following list.

- <dfn>Search</dfn> is displayed more prominently and allows for searching by type of object (for example, searching for "products" allows direct navigation to the products index screen)
- A sitemap-like <dfn>primary navigation</dfn> organizes the Admin into sections, each with their own dashboard and subsections
- <dfn>Hierarchical navigation</dfn> is designed around the main heading of the page, with the link above the main heading going a level "up" the taxonomy, and links below the main heading going "down" a level deeper
- <dfn>Auxiliary navigation</dfn> that sometimes appears in the top right navigates between pages that are related but in a different parts of the taxonomy, such as returning to a product from its related inventory
- Redesigned <dfn>index pages</dfn> use a grid layout and allow selecting multiple products for <dfn>bulk actions</dfn>, such as edit and delete
- Objects such as products and categories now have <dfn>show pages</dfn> that present an overview of everything that can be managed for that object, as well as decomposing the administration of that object into smaller, more manageable pieces
- On show pages, <dfn>cards</dfn> bring forward comments and other features that were hidden behind context menus in previous versions
- The <dfn>timeline</dfn> for an object combines its history and upcoming changes into a single chronological view
- The <dfn>current release</dfn> is stored in session so that it "follows" the user through the Admin, while controls on most screens allow editing the current release before editing and before saving
- <dfn>Creation workflows</dfn> provide step-by-step interfaces to create and publish objects such as products, categories, and discounts that require more than a simple form to create a functioning whole (for example, _products_ need _variants_ that need _prices_)
- The <dfn>content editing</dfn> UI is redesigned, providing more context while editing, as well as improved previewing
- More useful data is present on <dfn>dashboards</dfn>, and <dfn>insights</dfn> are also available for categories, products, people, and search to help retailers make decisions

### Admin Toolbar

The admin toolbar that displays for administrators when browsing the Storefront is updated to match the Admin, providing the full Admin search and navigation directly within the Storefront. Administrators can navigate easily between Admin and Storefront views of the same object.

### Internationalization

In addition to being redesigned, the Admin UI has been internationalized, allowing for translation into different and multiple locales. The Storefront and Admin UIs are now both internationalized.
