---
title: Decoration
created_at: 2018/10/11
excerpt: Decoration is an extension technique that allows Workarea applications and plugins to modify Ruby classes provided by the Workarea platform and other Ruby libraries. Ruby is a dynamic language that allows classes (and their instances) to be modifie
---

# Decoration

<dfn>Decoration</dfn> is an extension technique that allows Workarea applications and plugins to modify Ruby classes provided by the Workarea platform and other Ruby libraries. Ruby is a dynamic language that allows classes (and their instances) to be modified during runtime, however the syntax and APIs that Ruby provides for this purpose can be confusing to less experienced Ruby developers. Workarea therefore leverages <cite>Rails::Decorators</cite> ([gem](https://rubygems.org/gems/rails-decorators/versions/0.1.2), [docs](http://www.rubydoc.info/gems/rails-decorators/0.1.2), [source](https://github.com/weblinc/rails-decorators)), an open source Ruby library also maintained by Workarea, to simplify the process of extending classes.

Rails::Decorators specifies a DSL (based on Rails' [ActiveSupport::Concern](http://www.rubydoc.info/gems/activesupport/5.1.4/ActiveSupport/Concern)) to be used within <dfn>decorators</dfn>, which are Ruby files whose names end with _.decorator_. Each decorator extends one or more Ruby classes. Rails::Decorators ensures decorators within applications and plugins are autoloaded _after_ Rails autoloads the class definitions from the application and its dependencies.

## Decorators

Decorators allow application and plugin authors to extend existing Ruby classes in the following ways.

- Add new instance and class methods to a class
- Modify existing instance and class methods, with access to the pre-decoration implementation via `super`
- Execute class macros or other code as if you were in the original class definition

Because decorators contain only _differences_ from the classes they are extending, they are more lightweight than other extension techniques that completely replace the code to be customized. During an upgrade, if code you've decorated has changed, you may need to update your decorators. However, code changes you haven't decorated will be applied seamlessly to your application without additional upgrade cost.

## Decorator Example

I extracted the following example from the [Workarea Package Products](https://github.com/workarea-commerce/workarea-package-products) plugin and present it here with minor edits and annotations to demonstrate the structure of a decorator. Review the [Rails::Decorators documentation](http://www.rubydoc.info/gems/rails-decorators/0.1.2) for more details.

```ruby
# workarea-package_products-3.1.0/app/models/workarea/catalog/product.decorator
# The path of the decorator mimics the path of the class to be decorated

# Open namespace for convenience (to avoid fully qualified constants)
module Workarea
  # Pass the classes to be decorated and any options to 'decorate', along with a block
  # Decorators within plugins use the 'with' option to avoid naming collisions (see text below)
  decorate Catalog::Product, with: :package_products do
    # Code within the 'decorated' block is executed as if it were included in the class definition
    # Use this block to execute class macros or other metaprogramming
    decorated do
      include FeaturedProducts

      scope :packages_containing, ->(id) { where('product_ids' => id) }
    end

    # Use the 'class_methods' block to add and modify class methods
    class_methods do
      def find_for_update_by_sku(sku)
        where('variants.sku' => sku).flat_map do |product|
          [product] + packages_containing(product.id)
        end
      end
    end

    # Add and modify instance methods directly within the 'decorate' block

    def package?
      template == 'package' || product_ids.present?
    end

    def family?
      template == 'family'
    end

    def active?
      (read_attribute(:active) && variants.active.any? || product_ids.present?)
    end

    def purchasable?
      # Use 'super' to find the same method in the ancestor chain and invoke it
      # This provides access to the "pre-decorated" implementation (see examples below)
      super && package?
    end
  end
end
```

## Decorating Tests

Because [tests](/articles/testing-concepts.html) are Ruby methods, you can extend tests by decorating test cases, the classes in which test methods are defined. When decorating features, you should always decorate the corresponding tests as well.

The following examples from [Workarea Browse Option](https://github.com/workarea-commerce/workarea-browse-option) demonstrate the need to decorate a feature and its tests together. In the first example, Browse Option decorates `Search::ProductEntries` so that products that "browse by option" are represented by multiple documents in Elasticsearch. This is new functionality, not covered by the existing test suite, so the plugin also decorates `Search::ProductEntriesTest` adding a new test to confirm the behavior.

```ruby
# workarea-browse_option-1.1.0/app/queries/search/product_entries.decorator

module Workarea
  decorate Search::ProductEntries, with: :browse_option do
    def index_entries_for(product)
      if product.browses_by_option?
        product.browse_options.map do |value|
          Search::Storefront::ProductOption.new(
            product,
            option: product.browse_option,
            value: value
          )
        end
      else
        super
      end
    end
  end
end

# workarea-browse_option-1.1.0/test/queries/workarea/search/product_entries_test.decorator

require 'test_helper'

module Workarea
  decorate Search::ProductEntriesTest, with: :browse_option do
    def test_browse_option_entries
      products = Array.new(2) { create_product }

      products.first.update_attributes!(
        browse_option: 'color',
        variants: [
          { sku: 'SKU1', details: { color: ['Red'] } },
          { sku: 'SKU2', details: { color: ['Blue'] } }
        ]
      )

      assert(3, Search::ProductEntries.new(products).entries.size)
    end
  end
end
```

In the next example, Browse Option decorates `BulkIndexProducts`, changing the behavior of `perform_by_models`. This change breaks an existing test for `perform`, since `perform_by_models` is used in that method's implementation. The plugin therefore decorates `BulkIndexProductsTest` as well, in order to fix the test for `perform`.

```ruby
# workarea-browse_option-1.1.0/app/workers/workarea/bulk_index_products.decorator

module Workarea
  decorate BulkIndexProducts, with: :browse_option do
    class_methods do
      def perform_by_models(products)
        return if products.blank?

        documents = delete_actions(products) +
          Search::ProductEntries.new(products).map(&:as_bulk_document)

        Search::Storefront.bulk(documents)
        products.each { |p| p.set(last_indexed_at: Time.current) }
      end

      # ...
    end
  end
end

# workarea-browse_option-1.1.0/test/workers/workarea/bulk_index_products_test.decorator

require 'test_helper'

module Workarea
  decorate BulkIndexProductsTest, with: :browse_option do
    def test_peform
      Workarea::Search::Storefront.reset_indexes!

      Sidekiq::Callbacks.disable(IndexProduct) do
        products = Array.new(2) { create_product }

        assert_equal(0, Search::Storefront.count)
        BulkIndexProducts.new.perform(products.map(&:id))
        assert_equal(2, Search::Storefront.count)

        products.first.update_attributes!(
          browse_option: 'color',
          variants: [
            { sku: 'SKU1', details: { color: ['Red'] } },
            { sku: 'SKU2', details: { color: ['Blue'] } }
          ]
        )

        assert_equal(2, Search::Storefront.count)
        BulkIndexProducts.new.perform(products.map(&:id))
        assert_equal(3, Search::Storefront.count)
      end
    end

    # ...
  end
end
```

(
See also [Decorate & Write Tests](/articles/decorate-and-write-tests.html).
)

## Compounding Decorators

Multiple engines may decorate the same class, in which case the effects of the decorators are cumulative. Decorators within the application are prepended last, giving them the opportunity to modify their classes after all plugin decorators.

For example, I've created a new application and added the following decorator within my app to begin implementing a loyalty program.

```ruby
# app/models/workarea/catalog/product.decorator

module Workarea
  decorate Catalog::Product do
    decorated do
      field :loyalty_points, type: Integer, default: 100
    end

    def loyalty_promo?
      loyalty_points > 100
    end
  end
end
```

My application depends on several Workarea plugins.

```bash
$ grep 'workarea' Gemfile
gem 'workarea', '~> 3.1.0'
gem 'workarea-blog'
gem 'workarea-browse_option'
gem 'workarea-clothing'
gem 'workarea-content_search'
gem 'workarea-package_products'
gem 'workarea-reviews'
gem 'workarea-share'
```

Most of these plugins include the same decorator I've included in my application. In the example below, I search for the path _workarea/catalog/product_ within my application and its dependencies. In the results, you can see the following.

- The original Product model from Workarea Core
- The Product decorator I added to my application
- Four additional Product decorators, one each from Workarea Browse Option, Workarea Clothing, Workarea Package Products, and Workarea Reviews

```bash
$ find . -path '*workarea/catalog/product.*'
./app/models/workarea/catalog/product.decorator
./vendor/ruby/2.4.0/gems/workarea-browse_option-1.1.0/app/models/workarea/catalog/product.decorator
./vendor/ruby/2.4.0/gems/workarea-clothing-2.1.0/app/models/workarea/catalog/product.decorator
./vendor/ruby/2.4.0/gems/workarea-core-3.1.1/app/models/workarea/catalog/product.rb
./vendor/ruby/2.4.0/gems/workarea-package_products-3.1.0/app/models/workarea/catalog/product.decorator
./vendor/ruby/2.4.0/gems/workarea-reviews-2.1.0/app/models/workarea/catalog/product.decorator
```

To quickly demonstrate the effect of multiple decorators on the Product class, the following example (which I've annotated) lists the class's immediate ancestors.

```bash
$ bin/rails r 'puts Workarea::Catalog::Product.ancestors' | grep 'Workarea'
Workarea::Catalog::Product::ProductDecorator # application decorator
Workarea::Catalog::Product::ReviewsProductDecorator # |
Workarea::Catalog::Product::PackageProductsProductDecorator # |-- plugin decorators
Workarea::Catalog::Product::ClothingProductDecorator # |
Workarea::Catalog::Product::BrowseOptionProductDecorator # |
Workarea::Catalog::Product # original class
Workarea::FeaturedProducts
Workarea::Details
Workarea::Commentable
Workarea::Navigable
Workarea::Releasable
Workarea::ApplicationDocument
```

When looking up methods originally defined in this class, Ruby will actually look through the modules and classes as they are ordered above (top to bottom). Note the plugin decorator modules are searched before the original class, and they are searched in the opposite order the plugins are included in the Gemfile. Each plugin decorator module has a prefix that is derived from the value of the `:with` option in the decorator. The `:with` value must be unique to the ecosystem to avoid naming conflicts.

The application decorator module is searched first. Notice it does not have a prefix, because the `:with` option is omitted from the decorator, which is common practice for application decorators. Because the application decorator module is searched first, it has the responsibility of resolving any conflicts resulting from the culmination of the other decorators.

## Super

Within a decorator's method definitions, calling `super` results in calling the same method on the closest ancestor in which it is defined. An example ancestor chain is shown above. As you can see from that example, a decorator may in fact be extending another decorator. Furthermore, calling `super` has various applications that may not be immediately obvious. The following examples, taken from various plugins, demonstrate uses of `super` within decorators.

In the following examples, <dfn>command</dfn> refers to a method concerned with side effects, while <dfn>query</dfn> refers to a method concerned with a return value.

### Prepend to a Command

```ruby
# workarea-browse_option-1.1.0/app/workers/workarea/index_product.decorator

module Workarea
  decorate IndexProduct, with: :browse_option do
    class_methods do
      def perform(product)
        clear(product)
        super
      end

      def clear(product)
        # ...
      end
    end
  end
end
```

### Conditionally Append to a Command

```ruby
# workarea-package_products-3.1.0/app/controllers/workarea/storefront/products_controller.decorator

module Workarea
  decorate Storefront::ProductsController, with: :package_products do
    def show
      super
      render 'package_show' if @product.package?
    end
  end
end
```

### Conditionally Replace a Command

```ruby
# workarea-content_search-1.0.1/app/controllers/workarea/storefront/searches_controller.decorator

module Workarea
  decorate Storefront::SearchesController, with: :content_search do
    # ...

    def set_search(response)
      if response.template == 'content'
        @search = Storefront::ContentSearchViewModel.new(response, view_model_options)
      else
        super
      end
    end
  end
end
```

### Append to a Query

```ruby
# workarea-reviews-2.1.0/app/models/workarea/search/storefront/product.decorator

module Workarea
  decorate Search::Storefront::Product, with: :reviews do
    def sorts
      super.merge(
        rating: Review.find_sorting_score(model.id)
      )
    end
  end
end

# workarea-reviews-2.1.0/app/queries/workarea/search/product_search.decorator

module Workarea
  decorate Search::ProductSearch, with: :reviews do
    class_methods do
      def available_sorts
        super.tap { |sorts| sorts << Sort.top_rated }
      end
    end
  end
end
```

### Conditionally Prepend to a Query

```ruby
# workarea-browse_option-1.1.0/app/view_models/workarea/storefront/product_view_model/cache_key.decorator

module Workarea
  decorate Storefront::ProductViewModel::CacheKey, with: :browse_option do
    # ...

    def option_parts
      option = @product.browse_option
      return super unless option.present? && @options[option].present?

      super.unshift(@options[option])
    end
  end
end
```

### Conditionally Replace a Query

```ruby
# workarea-package_products-3.1.0/app/queries/workarea/search/product_entries.decorator

module Workarea
  decorate Search::ProductEntries, with: :package_products do
    def index_entries_for(product)
      return Search::Storefront::PackageProduct.new(product) if product.package?
      super
    end
  end
end
```

## Decorator Generator

Workarea provides a Rails generator that application developers can use to create a new decorator within an application. Given the path (relative to the engine root) to a file where a Workarea class is defined, the generator will create a decorator for that class within the application. The generator will also try to create decorators for applicable tests.

Run the generator with the _--help_ option for documentation and examples. The following example is from my demonstration app running Workarea 3.1.1.

```bash
$ bin/rails g workarea:decorator --help
Usage:
  rails generate workarea:decorator PATH [options]

Runtime options:
  -f, [--force] # Overwrite files that already exist
  -p, [--pretend], [--no-pretend] # Run but do not make any changes
  -q, [--quiet], [--no-quiet] # Suppress status output
  -s, [--skip], [--no-skip] # Skip files that already exist

Description:
    Generates a new decorator for a given PATH in a Workarea platform
    component (or plugin), and a decorator for its unit test from the existing
    codebase in your host app.

Example:
    rails generate workarea:decorator app/models/workarea/search/storefront/product.rb

    This will create:
        app/models/workarea/search/storefront/product.decorator
        test/models/workarea/search/storefront/product_test.decorator (if a test exists)

    If no tests exist, it will also show a huge warning message stating the class you're
    about to decorate has NO tests, so anything you change must be also
    verified in the unit tests.
```
