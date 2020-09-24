---
title: Change the Storefront Product Pricing UI 
created_at: 2019/03/28
excerpt: An overview of how Workarea displays pricing for products and how to customize its UI.
---

# Change the Storefront Product Pricing UI 

A common customization for projects is making updates to the way pricing is displayed for a given product. In this guide we will outline the basics of how a product's price is displayed within the browser and how to make adjustments to said presentation.

## Overview

In the Workarea platform you can imagine a product as a group of items for sale. Each item's price is determined via a `Pricing::Price` object embedded within the item's `Pricing:Sku`. Each `Pricing::Price` contains fields that set the "regular" and, optionally, "sale" price for that item. It are these objects that allow the displayed "sell" price for the product to be derived.

When browsing the catalog (categories, products, content blocks, etc), only generic prices are shown out-of-the-box. A generic price refers to the price being usable without additional information, such as quantity or segment influence. As soon as items are priced in an order, the most specific prices available will be applied.

```ruby
# core/app/models/workarea/pricing/price.rb
module Workarea
  module Pricing
    class Price
      ...
      field :min_quantity, type: Integer, default: 1
      field :regular, type: Money, default: 0
      field :sale, type: Money
      ...
      def generic?
        min_quantity == 1
      end
      ...
    end
  end
end
```

```ruby
# core/app/models/workarea/pricing/sku.rb
module Workarea
  module Pricing
    class Sku
      ...
      embeds_many :prices, class_name: 'Workarea::Pricing::Price'
      ...
    end
  end
end
```

It should be noted that, in addition to "regular" and "sale" prices, `Pricing::Sku`s may also set an MSRP for the item, though it is not used in the actual pricing calculation.

## Presentation

A product's presentation is determined by the help of its view model. In this case we're concerned with the `ProudctViewModel#pricing` method:

```ruby
module Workarea
  module Storefront
    class ProductViewModel < ApplicationViewModel
      ...
      delegate :sell_min_price, :sell_max_price, :on_sale?, :has_prices?, to: :pricing

      def pricing
        @pricing ||= options[:pricing] || Pricing::Collection.new(
          options[:sku].presence || variants.map(&:sku)
        )
      end
      ...
    end
  end
end
```

This method returns a `Pricing::Collection` which represents every instance of `Pricing::Price` for the product. It should be noted, however, that if the user has selected a SKU as "current" only that current SKU's price will be returned by this method.

The `Pricing::Collection` returned by `ProductViewModel#pricing` derives the minimum and maximum regular, sale, sell, and MSRP from all "generic" prices found.

The product view model also adds a concept of an "original" price, which will either be:

* the MSRP or
* the "regular" price, if the MSRP is assumed to be greater

Lastly the product view model also has logic to determine if the same and original prices should be displayed, and whether the sell and original prices should be displayed as a specific price or as a price range.

## Styling

The styling for the Product Prices UI is provided by the `product-prices` SCSS component. Each element containing a price carries a class which may be styled as needed. Here is an overview of this Stylesheet:

```css
/* app/assets/stylesheets/workarea/storefront/components/_product_prices.scss */
.product-prices {}

.product-prices--summary {}
.product-prices--details {}

    .product-prices__price {}

    .product-prices__price--single {}
    .product-prices__price--multiple {}
    .product-prices__price--on-sale {}
    .product-prices__price--original {}

        .product-prices__sell-price {}
        .product-prices__sell-price--min {}
        .product-prices__sell-price--max {}

        .product-prices__original-price {}
```

The `.product-prices` component is used in multiple sections of the application, each of which are accounted for within the associated component's style guide. When customizing the styles you are encouraged to develop against and maintain the style guide examples.

## Markup

The aforementioned class names are applied to the product pricing partial, which handles the many display conditions of the price. The logical permutations are as follows:

* if the product has only one price
  * and if the product should show a range of prices
  * or if the product should show a single price
* if the product has multiple prices
  * and if the product is on sale
    * and if the product should show a range of prices
    * or if the product should show a single price
  * or if the product is not on sale
    * and if the product should show a range of prices
    * or if the product should show a single price

The product pricing partial will always show the determined original price by default.

```haml
-# app/views/workarea/storefront/products/_pricing.html.haml
- cache "#{product.cache_key}/prices", expires_in: Workarea.config.cache_expirations.product_pricing_fragment_cache do
  - if product.one_price?
    %p.product-prices__price
      - if product.show_sell_range?
        %span.product-prices__sell-price.product-prices__sell-price--min
          = number_to_currency(product.sell_min_price)
        %span.product-prices__sell-price.product-prices__sell-price--max – #{number_to_currency product.sell_max_price}
      - else
        %span.product-prices__sell-price
          = number_to_currency(product.sell_min_price)

  - else
    - if product.on_sale?
      %p.product-prices__price.product-prices__price--on-sale
        - if product.show_sell_range?
          %strong.product-prices__sell-price.product-prices__sell-price--min
            = number_to_currency(product.sell_min_price)
          %strong.product-prices__sell-price.product-prices__sell-price--max – #{number_to_currency product.sell_max_price}
        - else
          %strong.product-prices__sell-price
            = number_to_currency(product.sell_min_price)

    - else
      %p.product-prices__price
        - if product.show_sell_range?
          %span.product-prices__sell-price.product-prices__sell-price--min
            = number_to_currency(product.sell_min_price)
          %span.product-prices__sell-price.product-prices__sell-price--max – #{number_to_currency product.sell_max_price}
        - else
          %span.product-prices__sell-price
            = number_to_currency(product.sell_min_price)

    %p.product-prices__price.product-prices__price--original
      - if product.show_original_range?
        %s.product-prices__original-price.product-prices__original-price--range #{number_to_currency product.original_min_price} – #{number_to_currency product.original_max_price}
      - else
        %s.product-prices__original-price= number_to_currency product.original_min_price

  = append_partials('storefront.product_pricing', product: product)
```

As you can see we use `strong` and `s` HTML tags within these which carry semantic value.

This partial is rendered within the product details and summary views, each applying their own modifier to the component, which allows these components to be conditionally styled based on which page they appear.

## Caching

The product pricing code is partialized to make use of fragment caching, which you can see at the top of this file, above. Because of the cache the markup for every place the markup is output must be the same. This is another reason why the parent `.product-prices` component lives outside of the partial and provides the unique styling hooks for both the product detail and product summary views. These classes are:

* `product-prices--details`
* `product-prices--summary`

Each usage of the product pricing partial is further cached by either the product detail or product summary view, using the following fragment cache keys:

* `config.cache_expirations.product_show_fragment_cache`
* `config.cache_expirations.product_summary_fragment_cache`

Additional fragment caches may be added as well, such as if the summary is an recommended product inside the product detail page.

## Recommendations in Storefront emails

The product pricing partial is also referenced by the recommendations mailer view, for use in generating recommendations for users of the site.

Styling for this markup is provided by the `.product-grid` component that lives inside the `email` Stylesheet directory, specifically in:

```scss
/* app/assets/stylesheets/workarea/storefront/email/_components.scss */
.product-grid {
    & > tr > td {
        vertical-align: top;
    }
}

    .product-grid__product {
        text-align: center;
    }

        .product-grid__image {
            padding: 0 0 $spacing-unit;
        }

        .product-grid__info {
            padding: 0 0 ($spacing-unit * 2);
            font-size: $font-size - 2px;
            font-family: $font-family;
        }

            .product-grid__link {
                text-decoration: none;
            }

            .product-grid__name {
                display: block;
            }

            .product-grid__price {
                font-weight: bold;
            }
```

The styling for the pricing partial is provided specifically by the `.product-grid__price` class, above.

## Example Customization

The `product-prices` component is often customized to satisfy design and further clarify each price that is output. In this example we'll start by styling the Sell and Original prices green and gray, respectively, to make the actual price of the product stand out more.

If the `product-prices` component has not yet been overridden in your project, override it using:

```sh
bin/rails g workarea:override stylesheets storefront/components/_product_prices.scss
```

Inside of this component you will find many classes, but the two that are of interest to us are

```scss
.product-prices__sell-price {}
.product-prices__original-price {}
```

First we should add a few functional color variables to the top of the component to help us quickly reskin or theme this UI for use in another multi-site instance. Then we should add these colors to each class. We'll assume that the colors variables `$green` and `$gray` are already defined within the `workarea/storefront/settings/_colors.scss` file: 

```scss
// app/assets/stylesheets/workarea/storefront/components/_product_prices.scss

/*------------------------------------*\
    #PRODUCT-PRICES
\*------------------------------------*/

$product-prices-sell-price-color: $green !default;
$product-prices-original-price-color: $gray !default;

.product-prices {}

...

.product-prices__sell-price {
    color: $product-prices-sell-price-color;
}

.product-prices__original-price { 
    color: $product-prices-original-price-color;
} 
```

Now the UI should be a bit clearer to the user, but sometimes designers or clients find price ranges to be confusing as well. Another common customization is to show a minimum price only, using a "From" label to show the product's lowest price.

To do this we'll first need to add an entry to our locale file, for use in the partial. If it does not yet exist, you can create one in the `config/locales/` directory.

```yaml
# config/locales/en.yml
en:
  workarea:
    storefront:
      ...
      products:
        ... 
        min_price_label: "From:"
      ...
```

Next we'll add the new locale to the product pricing partial, removing the elements containing the max price from all sell price ranges as well: 

```haml
- cache "#{product.cache_key}/prices", expires_in: Workarea.config.cache_expirations.product_pricing_fragment_cache do
  - if product.one_price?
    %p.product-prices__price
      - if product.show_sell_range?
        %span.product-prices__sell-price.product-prices__sell-price--min
          = t('workarea.storefront.products.min_price_label')
          = number_to_currency(product.sell_min_price)
        %span.product-prices__sell-price.product-prices__sell-price--max – #{number_to_currency product.sell_max_price}
      - else
        %span.product-prices__sell-price
          = number_to_currency(product.sell_min_price)

  - else
    - if product.on_sale?
      %p.product-prices__price.product-prices__price--on-sale
        - if product.show_sell_range?
          %strong.product-prices__sell-price.product-prices__sell-price--min
            = t('workarea.storefront.products.min_price_label')
            = number_to_currency(product.sell_min_price)
          %strong.product-prices__sell-price.product-prices__sell-price--max – #{number_to_currency product.sell_max_price}
        - else
          %strong.product-prices__sell-price
            = number_to_currency(product.sell_min_price)

    - else
      %p.product-prices__price
        - if product.show_sell_range?
          %span.product-prices__sell-price.product-prices__sell-price--min
            = t('workarea.storefront.products.min_price_label')
            = number_to_currency(product.sell_min_price)
          %span.product-prices__sell-price.product-prices__sell-price--max – #{number_to_currency product.sell_max_price}
        - else
          %span.product-prices__sell-price
            = number_to_currency(product.sell_min_price)

    %p.product-prices__price.product-prices__price--original
      - if product.show_original_range?
        %s.product-prices__original-price.product-prices__original-price--range #{number_to_currency product.original_min_price} – #{number_to_currency product.original_max_price}
      - else
        %s.product-prices__original-price= number_to_currency product.original_min_price

  = append_partials('storefront.product_pricing', product: product)
```

This change will undoubtedly break some tests. The tests pertaining to pricing live in the Storefront's product's system test. As an example we'll modify the `test_showing_a_product` test method in a decorator:

```ruby
# test/workarea/storefront/products_system_test.decorator

require 'test_helper'

module Workarea
  decorate Storefront::ProductsSystemTest do
      def test_showing_a_product
        visit storefront.product_path(@product)
        assert(page.has_content?('Integration Product'))
        assert(page.has_content?('From: $10.00'))
        refute_text('$15.00')
        assert(page.has_select?('sku', options: ['Select options', 'SKU1', 'SKU2', 'SKU3']))
      end
  end
end
```

Similar customizations may need to be made to test methods in this file as well.
