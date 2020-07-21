---
title: Add Catalog Customizations
excerpt: This guide shows you how to implement user-defined customizations for the products in your catalog.
---

# Add Catalog Customizations

Customizations are pre-defined fields for your product that customers can use
to create personalized, custom versions of that product. Some examples of how
these have been used include:

* Custom engravings for jewelry
* Monograms for shirts
* Email addresses for digital gift cards 

## Step 1: Create a `Catalog::Customizations` subclass

The first step is to subclass `Workarea::Catalog::Customizations` with
something descriptive of your customization. In this case, we'll be using the
concept of an "engraving" for jewelry. Create a file named
**app/models/workarea/catalog/customizations/engraving.rb** and populate it
with the following class definition:

```ruby
module Workarea
  module Catalog
    class Customizations::Engraving < Customizations
      customized_fields :initials
      validates_presence_of :initials
    end
  end
end
```

The `Catalog::Customizations` base class provided by Workarea mixes in the
[ActiveModel::Validations](https://guides.rubyonrails.org/active_record_validations.html)
module, allowing you to use the same validation logic as you're used to using
in Mongoid models.

## Step 2: Add To Configuration

In order to allow admins to choose this class of customizations after the site
has launched, add your class to configuration:

```ruby
Workarea.configure do |config|
  config.customization_types << 'Workarea::Catalog::Customizations::Engraving'
end
```

**Be sure to always use a `String` here to represent your class!! Constants may
not get duplicated correctly in multi-site installs.**

## Step 3: Apply Customizations to a Product

Choose the product that you wish to apply customizations on, and set the
`:customizations` field on the model:

```ruby
product = Workarea::Catalog::Product.find('0-XABC12345')
product.update!(customizations: 'engraving')
```

(You can also do this in the admin)

Now, any time someone orders this product, they will have the option to engrave
it. All input from the customer is validated according to the rules specified
in your subclass. When valid and the item is added to cart, these customized
attributes are stored on the `Order::Item` like so:

```ruby
order = Workarea::Order.last
order.items.first.customizations
# => { initials: "ABC" }
```

This would then get passed on to your ERP or OMS for further processing as you
see fit.

## Step 4: Add Customizations to Product Template(s)

In order to allow users to customize their products, you'll need to append fields into the "add to cart" form on the product detail page. The easiest way to do this is to append a partial to the `storefront.add_to_cart_form` section in your initializers:

```ruby
Workarea.append_partials(
  'storefront.add_to_cart_form',
  'workarea/storefront/path/to/your/partial'
)
```

Your partial code should include fields for changing the customization:

```haml
.property
  = label_tag :initials, 'Your Initials'
  .property__value
    = text_field_tag :initials
```

This will be rendered within the `<form>` to add the product to cart.

**NOTE:** When added to the item, your customizations will appear just below the item details in the cart.

## Step 5: (optional) Apply a Pricing SKU to the Customization.

To charge for customizations, you can use a `Pricing::Sku` and set prices on
that SKU (the `#id` field), then provide the SKU in your customizations'
attributes:

```ruby
module Workarea
  module Catalog
    class Customizations::Engraving < Customizations
      customized_fields :initials
      validates_presence_of :initials

      def attributes
        super.merge(pricing_sku: 'SKU123')
      end
    end
  end
end
```

When the item is added to cart and customization validations pass, this pricing
SKU will be used to price out the additional charge necessary for the
customization.
