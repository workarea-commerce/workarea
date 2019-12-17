---
title: Add or Replace a Pricing Calculator
created_at: 2018/11/27
excerpt: Learn how to manipulate pricing calculators to affect how products and orders are priced on your Workarea application.
---

# Add or Replace a Pricing Calculator

In this article, you'll learn how to extend the pricing logic in Workarea to fit the needs of your application, by [generating](#generating-pricing-calculators) and [configuring](#configuring-pricing-calculators) its pricing calculators. Workarea's pricing system is constructed in such a way that it is possible to replace, rather than decorate, the way by which pricing is calculated on items and products. This includes adding pricing calculators for adjusting price, removing pricing calculators to omit certain price adjustments, and replacing out-of-box pricing calculators with your additional functionality.

But before diving into creating your own pricing calculators, let's have a look at the calculators Workarea provides for you out-of-the-box...

Four pricing calculators are included in Workarea, each addressing a different portion of the price which are added together to formulate the final grand total. They are as follows, and perform their pricing adjustments in the following order:

1. **Workarea::Pricing::Calculators::ItemCalculator** sets the base unit price of the item. Override this to change the base item price, such as when working within segmentation.
2. **Workarea::Pricing::Calculators::CustomizationsCalculator** adjusts the price based on whether any customizations to the item were set.
3. **Workarea::Pricing::Calculators::DiscountCalculator** uses the [discounts subsystem](/articles/create-a-custom-discount.html) to apply discounts to the order. This should typically not be overridden or replaced. Instead, admins can create discounts that surpass the functionality of a simple pricing calculator.
3. **Workarea::Pricing::Calculators::TaxCalculator** applies tax to the order using the built-in tax tables that are available in the database. These tax tables can be imported by the user in Avalara format, or created manually through the admin. This also does not typically need to be changed, since the default functionality is to not charge tax when there are no tax tables present for your locale.

## Generating Pricing Calculators

To extend the functionality of pricing, new pricing calculators can be created in your Workarea application that are either entirely new, or replace an existing calculator to apply additional functionality. It's always recommended to add a new calculator somewhere in the chain, creating an additional `PriceAdjustment`, and thus creating a "paper trail" of price changes for each item in the order. This helps when debugging why items are priced in certain ways within the order, as well as when you need additional data from the pricing system for integrations (such as to an OMS).

To create a new calculator, use the `workarea:pricing_calculator` generator:

```bash
$ rails generate workarea:pricing_calculator Tariff
```

This will create a file in your application at **app/models/workarea/pricing/calculators/tariff_calculator.rb**:

```ruby
module Workarea
  module Pricing
    module Calculators
      class TariffCalculator
        include Calculator

        def adjust
          # TODO implement me
        end
      end
    end
  end
end
```

The generator will also create a corresponding test class in **test/models/workarea/pricing/calculators/tariff_calculator_test.rb**:

```ruby
require 'test_helper'

module Workarea
  module Pricing
    module Calculators
      class TariffCalculatorTest < TestCase
        def test_adjust
          # TODO assert that the calculator adds price adjustments
        end
      end
    end
  end
end
```

In this test class, you can use `TariffCalculator.test_adjust(order, shipping)` to simulate a pricing adjustment on the order without necessarily having to perform a `Pricing::Request`. Create a `Workarea::Order` (and optionally a `Workarea::Shipping`) that will have tariffs charged on it, as well as one that shouldn't have tariffs charged, in order to ensure your new functionality works. Here's an example of how you might do that:

```ruby
require 'test_helper'

module Workarea
  module Pricing
    module Calculators
      class TariffCalculatorTest < TestCase
        def test_adjust
          order = create_order
          order.add_item(product_id: 'PRODUCT', sku: 'SKU', quantity: 1)

          TariffCalculator.test_adjust(order)

          adjustment = order.items.first.price_adjustments.last

          refute_nil(adjustment)
          assert_equal('item', adjustment.price)
          assert_equal(10.to_m, adjustment.amount)
        end
      end
    end
  end
end
```

To make this example test pass, implement the `#adjust` method on your calculator:

```ruby
def adjust
  order.items.each do |item|
    next unless shipping.charges_tariff?

    item.adjust_pricing(
       price: 'tax',
       amount: shipping.address.tariff.amount,
       quantity: item.quantity,
       calculator: self.class.name,
       description: 'A Very Draconian Tariff',
       data: { 'tariff_id' => shipping.address.tariff.id }
    )
  end
end
```

## Configuring Pricing Calculators

Now that you made a new pricing calculator, it must be added to your application's `pricing_calculators` configuration in order to take effect. This configuration setting is a `Workarea::SwappableList`.

In most cases, it's best to add your calculator somewhere in the list, typically after the default calculator for the price type. In the case of the previously-generated `TariffCalculator`, which makes a **tax** price adjustment, here's an example of adding the calculator *before* tax is calculated on the item:

```ruby
Workarea.configure do |config|
  # Charge tariff in addition to tax on some orders
  config.pricing_calculators.insert_before(
    'Workarea::Pricing::Calculators::TaxCalculator',
    'Workarea::Pricing::Calculators::TariffCalculator'
  )
end
```

Situations may also arise where you need pricing to be calculated in a special way *adjacent* to the existing pricing infrastructure. For this scenario, **add** your new calculator to the end of the list:

```ruby
Workarea.configure do |config|
  # Charge tariff after shipping/tax/customizations
  config.pricing_calculators.push('Workarea::Pricing::Calculators::TariffCalculator')
end
```

In rare cases, you may need to wholly replace the existing calculator. This is generally not necessary, and can cause compatibility issues if other plugins leveraging the pricing system are expecting the out-of-box calculator to work a certain way. However, if you want to replace a calculator in the chain, use the `#swap` method like so:

```ruby
Workarea.configure do |config|
  # Calculate interest on the order if necessary
  config.pricing_calculators.swap(
    'Workarea::Pricing::Calculators::TaxCalculator',
    'Workarea::Pricing::Calculators::TariffCalculator'
  )
end
```

Make sure you restart your server to see changes take effect.

**NOTE:** It's also possible to **remove** calculators from the config, but it is not advisable as doing so will cause issues in testing.
