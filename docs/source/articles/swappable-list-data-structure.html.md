---
title: SwappableList Data Structure
created_at: 2019/03/21
excerpt: "SwappableList is a data structure in Workarea, typically used for storing a mutatable list of values in the app configuration. Learn why it's used in the platform and how you can use it on your own projects in this guide."
---

# SwappableList Data Structure

Workarea introduces a new data structure in its configuration, called `Workarea::SwappableList`. Based on [Rails::Configuration::MiddlewareStackProxy](https://api.rubyonrails.org/classes/Rails/Configuration/MiddlewareStackProxy.html), the object used in `Rails.configuration.middleware`, a swappable list is useful for lists of configuration that may change based on the implementation. It's especially useful in the platform as a means of providing a default, ordered list of configured values that can be changed in an implementation without needing to know the full breadth of the list. Generally, Workarea uses Swappable Lists much like Rails and Rack do: Defining an enumerated list of class names that are "chained" together by some input and output a mutated result.

## Implementation

`Workarea::SwappableList` is an [Enumerable](https://ruby-doc.org/core/Enumerable.html) object that includes the following extra methods for mutating the data structure in place:

- `#insert` (aliased to `#insert_before`) for adding a new element to the end of the list, or before a given element in the list
- `#insert_after` for adding a new element after a given element in the list
- `#swap` for swapping two elements that already exist in the list

## Usage

Workarea uses Swappable Lists in all configuration settings that contain a collection of values. As described briefly above, this allows implementations and plugins to customize the order and content of these configuration settings without needing to know what the full content of the configuration setting was prior to changing it.

For example, in your project you may want to customize the way taxes are calculated. You don't want the original `Workarea::Pricing::Calculators::TaxCalculator` to run, you want your own class to take its place. To ensure Workarea uses your class instead of its own out-of-box implementation, you'll be using Swappable List's `#swap` method to replace your new value with the existing found value in the list:

```ruby
Workarea.configure do |config|
  config.pricing_calculators.swap(
    'Workarea::Pricing::Calculators::TaxCalculator',
    'Workarea::Pricing::Calculators::CustomTaxCalculator'
  )
end
```

Here's another example: Perhaps you are implementing a means of spending rewards points in exchange for a discounted price on customers orders. You still want the `DiscountCalculator` to apply for any other custom discounts the retailer may want to use, but right afterwards you can inject a `RewardsCalculator` to deduct money off of the order if rewards points are being spent on it. You can accomplish this by using the `#insert_after` method to find a given element in the list and place your element in the next position.

```ruby
Workarea.configure do |config|
  config.pricing_calculators.insert_after(
    'Workarea::Pricing::Calculators::DiscountCalculator',
    'Workarea::Pricing::Calculators::RewardsCalculator'
  )
end
```

You can also insert elements in the list before other elements, with the `#insert_before` method. This allows you to "prepend" functionality onto complex logical operations, like search. Here's an example of modifying search middleware by first checking whether the search term matches one of any product's keywords. When a keyword match is found, the `Workarea::Search::StorefrontSearch::KeywordRedirect` middleware class redirects the user to that product's URL instead of actually performing the search query.

```ruby
Workarea.configure do |config|
  config.storefront_search_middleware.insert_before(
    'Workarea::Search::StorefrontSearch::ProductMultipass',
    'Workarea::Search::StorefrontSearch::KeywordRedirect'
  )
end
```

Finally, since Swappable Lists mix in the `Enumerable` module, any of its methods to add or remove content are available in any Swappable List. Here's what the [share plugin](https://github.com/workarea-commerce/workarea-share) does in the initialization process to ensure that it adds its own sharing seeds so you can see how the plugin works:

```ruby
Workarea.config.seeds.push('Workarea::SharesSeeds')
# this is also equivalent to ...
Workarea.config.seeds << 'Workarea::SharesSeeds'
```

Swappable Lists can also be created ad-hoc for your own purposes. In **config/initializers/workarea.rb**:

```ruby
Workarea.configure do |config|
  # By default, the swappable list is empty
  config.order_export_middleware = Workarea::SwappableList.new

  # ...but you can also get it started with some default values
  config.product_import_middleware = Workarea::SwappableList.new([
    'Workarea::Mach::ProductImport::ProductAttributes',
    'Workarea::Mach::ProductImport::Variants',
    'Workarea::Mach::ProductImport::Inventory',
    'Workarea::Mach::ProductImport::Pricing',
    'Workarea::Mach::ProductImport::Persistence'
  ])
end
```

**NOTE:** You'll notice that swappable lists typically include class names, rather than their constants. It's a best practice when initializing Rails apps to not use any auto-loaded constants, as their actual place in memory may change between reloads. Instead, refer to classes by their String class names and `#constantize` them when the classes need to be instantiated.
