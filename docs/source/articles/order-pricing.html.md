---
title: Order Pricing
excerpt: This document provides information to help you develop the skills of explaining and extending order pricing.
---

Order Pricing
======================================================================

To facilitate [orders](/articles/orders.html)—transactions between shoppers and retailers, often including [shipping](/articles/shipping.html)—Workarea must reliably compute the prices for these transactions.
These computations include the price of each order item, potentially adjusted for customizations, overrides, and discounts;
and the overall price of the order, including shipping and tax, also potentially adjusted.

Fortunately, Workarea computes this information automatically and does not require any developer intervention.
However, as a developer, you must be prepared to _explain_ the pricing of a specific order or all orders to a retailer.
For example, a retailer may ask you why the total price of a particular order was unexpectedly low.
Or, you may need to explain why Workarea is computing tax subtotals differently than the retailer's accounting department.
Furthermore, you may need to _extend_ the pricing logic for a retailer, perhaps to charge a fee for gift wrapping, or to replace Workarea's tax calculations with those from an integrated service.

This document provides information to help you develop the skills of __explaining__ and __extending__ order pricing.
After reviewing an __example__ order and some shared __context__, you will learn the primary concepts to help you develop these skills.
Specifically, to explain _why_ an order is priced as it is, you should work backward from __pricing totals__, which are computed from __price adjustments__ by __pricing totals objects__.
To explain _how_ price adjustments are created, you should examine __pricing calculators__.
And to _change_ how price adjustments are created, you should implement your own pricing calculators which honor the __pricing calculator contract__, and re-configure the __pricing calculators collection__ to contain your custom calculators.

We'll explore each of these topics in turn, but first let's make things more concrete with an example.


Example Order
----------------------------------------------------------------------

Throughout this document, we'll use a specific order as a running example.
The following diagrams represent Storefront views of this order:

![Order pricing cart example](/images/order-pricing-cart-example.png)

![Order pricing placed order example](/images/order-pricing-placed-order-example.png)

The first diagram represents the order as a cart, while the second represents the same order after a shipping address is provided.
Both views of the order include computed pricing information.
The top two rows of each diagram represent _item-level_ prices, while the table following the line items represents _order-level_ prices.
_All_ of this pricing information is computed repeatedly until the order is placed.


Order Pricing in Context
----------------------------------------------------------------------

The pricing information for each order must be re-computed continually because Workarea's commerce model is cyclical.
Shoppers shop and admins manage, changing the states of various domain models.
The current states of these models must be reflected in the prices shown to shoppers and authorized on their payments.

The following diagram (adapted from [Commerce Model](/articles/commerce-model.html)) represents this cycle:

![Order pricing within the commerce model](/images/commerce-model-order-pricing.png)

Shoppers _create and manage carts_ by adding, removing, and updating order items and promo codes.
Shoppers additionally set the shipping address and shipping service within checkout, allowing them to _place the orders_.
Simultaneously, admins (and/or automated systems integrated with Workarea) _manage the catalog_ and _merchandise the store_ by manipulating SKU prices, sales, discounts (on items, orders, and shippings), shipping services, and tax rates.

To account for these ongoing changes, Workarea re-prices each cart before showing it to the shopper, including each checkout screen.
Each time a cart is priced, the results are a "snapshot" of the pricing for the transaction at that moment in time.
At the conclusion of checkout, when the order is placed, the pricing information is computed one last time and persisted as a permanent record (on the order, items, and shippings).

Familiarity with this lifecycle is indispensable when developing the skills of explaining and extending order pricing.
Let's move on to those specific skills.


Skill: Explaining Order Pricing
----------------------------------------------------------------------

From a system architecture perspective, `Pricing.perform` is the API call responsible for pricing orders.
Additionally, when setting the shipping address and shipping service in checkout, a call to `Shipping#set_shipping_service` precedes `Pricing.perform` to initiate pricing.

However, when a retailer questions the pricing of an order, you can likely trace their inquiry to a specific total or subtotal.
They may think the _total price_ of a particular order seems too low or the _tax subtotal_ seems to be off by a cent or two for most orders.
Therefore, to explain _why_ an order is priced as it is, you should work backward from __pricing totals__, which are computed from __price adjustments__ by __pricing totals objects__.


### Pricing Totals

_Pricing totals_ are computed money values stored within fields on each order, its items, and its associated shippings.
These fields represent the total price and various subtotals of the order transaction.

Many of these values are displayed to the shopper directly.
Examples are highlighted in the following diagram, which also indicates the underlying API calls to query the values.

![Totals within order pricing example](/images/order-pricing-example-totals.png)

There are additional totals fields, which are not shown in the above diagram.
For example, the total of each shipping is shown only when an order has multiple shippings.
Also, the total _value_ of an order or item is displayed in some Admin screens and used for calculations, such as discounts.

The following code example queries for _all_ pricing totals for our example order:

```ruby
order_id = '123321'

order = Workarea::Order.find(order_id)
items = order.items
shippings = Workarea::Shipping.by_order(order.id).to_a

puts order.subtotal_price
# 250.00
puts order.shipping_total
# 10.00
puts order.tax_total
# 2.00
puts order.total_price
# 202.00
puts order.total_value
# 190.00

puts items.first.total_price
# 100.00
puts items.first.total_value
# 76.00
puts items.last.total_price
# 150.00
puts items.last.total_value
# 114.00

puts shippings.first.shipping_total
# 10.00
puts shippings.first.tax_total
# 2.00
```

Querying the pricing totals for an order transaction is an important first step toward explaining the pricing for the order.
From a pricing total, you can work backward to specific __price adjustments__, which we explore next.


### Price Adjustments

_Price adjustments_ are documents embedded within order items and shippings that represent the "raw" pricing data for the order.
This data is used to calculate the order totals.
It may be helpful to think of the order totals as a credit card receipt which shows only a summary of what was charged to your card, while the price adjustments are collectively the "itemized" receipt with more granular details.

While most price adjustments are used internally—to compute totals—some are shown directly to shoppers.
The following diagram highlights and annotates the values in our placed order example that are read directly from price adjustments.

![Adjustments within order pricing example](/images/order-pricing-example-adjustments.png)

To explain the pricing for an order, look up the relevant adjustments.
Remember that these are documents embedded within the order's items and shippings.
The following code example queries for _all_ price adjustments for our example order:

```ruby
item_price_adjustments = items.map(&:price_adjustments).reduce(&:+)
shipping_price_adjustments = shippings.map(&:price_adjustments).reduce(&:+)
all_price_adjustments = item_price_adjustments + shipping_price_adjustments

all_price_adjustments.count
# => 10
all_price_adjustments.first.class
# => Workarea::PriceAdjustment
```

To understand how adjustments become totals, first examine a single price adjustment.
Most notably, it has a money `:amount`, either postive or negative, and a `:price`, which you should think of as a price _type_.
The price type is always one of `'item'`, `'order'`, `'shipping'`, or `'tax'`, and these are sometimes additionally referred to as "levels" (e.g. item-level vs order-level).
The adjustment document also has several metadata fields describing the price, including `:description`.

Now consider the adjustments in aggregate again.
The following diagram creates a visual "stack" of the adjustments for our example order, each with its amount, price type, and description.

![Price adjustments diagram](/images/price-adjustments-diagram.png)

To calculate `Order#total_price`, Workarea simply sums _all_ the amounts:

![Order total price diagram](/images/order-total-price-diagram.png)

All other order totals (i.e. subtotals) are calculated by summing a _subset_ of the same price adjustments.
The logic for each totals field is based on the adjustment price types and the objects on which they are stored.

For example, `Order#subtotal_price` is calculated by summing only the _item-level_ adjustments.

![Order subtotal price diagram](/images/order-subtotal-price-diagram.png)

Similarly, the shipping and tax totals are calculated by summing only the _shipping_ and _tax_ adjustments, respectively:

![Order shipping total diagram](/images/order-shipping-total-diagram.png)

![Order tax total diagram](/images/order-tax-total-diagram.png)

The total price for each _item_ is the sum of the item-level adjustments stored within that particular item.
The following diagram represents the total for the second item:

![Order item total price diagram](/images/order-item-total-price-diagram.png)

As a final example, the _total value_ of an order is the sum of its item- and order-level adjustments, or explained differently: the value of the _merchandise_, which includes most discounts, but excludes shipping and tax. (Expect a retailer or another developer to ask you about this; it's a common question).

![Order total value diagram](/images/order-total-value-diagram.png)

( If you're wondering why items embed both item- and order-level adjustments, or why some adjustments are embedded within shippings instead of items, we'll cover that with __pricing calulators__. )

The lesson here is each total can be deconstructed into a subset of the order transaction's price adjustments.
Recall the recipe for this: work backward from pricing totals, which are computed from price adjustments by __pricing totals objects__.
We'll therefore look at pricing totals objects next.


### Pricing Totals Objects

_Pricing totals objects_ are the objects responsible for calculating and writing the pricing totals to the order, items, and shippings each time an order is priced.
They encapsulate the logic for creating each pricing total from the "stack" of price adjustments for a given order and shippings.
Therefore, to deconstruct a total into price adjustments, you must look up the logic for that total within a pricing totals object, and reverse it.

The specific API calls that calculate and write the pricing totals are `OrderTotals#total` and `ShippingTotals#total`.
To find the implementations of these methods within your application or plugin, run the following command from your project's root:

```bash
find $(bundle show workarea-core) -path '*/app/*/pricing/*_totals.rb'
```

This command lists the pathnames of the classes where these methods are defined within your project.
Open the classes in your editor and locate the code assigning a value to the totals field you are trying to deconstruct.
From there, you can see which price adjustments factor into that total.
You may want to literally or metaphorically create a diagram like those above that show which of the adjustments contribute to a particular total.

(
Pricing totals objects use a special-purpose collection class, `PriceAdjustmentSet`, to subset and sum adjustments, thus creating totals.
These collections are effectively arrays with a few additional methods that encapsulate the logic for subsetting and summing based on the price type of the adjustments.
If you find these collections unintuitive, review the class definition and Mongoid extension that provides their behavior.
)

```bash
find $(bundle show workarea-core) -path '*/app/*/price_adjustment_*.rb'
```

After you've identified specific price adjustments, look at them more closely.
In addition to amount, price (type), and description, each adjustment has the additional fields `:calculator` and `:data`:

```ruby
sample_price_adjustment = all_price_adjustments.sample

sample_price_adjustment.calculator
# => "Workarea::Pricing::Calculators::ItemCalculator"

sample_price_adjustment.data
# => {"on_sale"=>true, "original_price"=>125.0, "tax_code"=>"simple"}
```

The `:calculator` field indentifies the class of object that created the adjustment when the order was last priced.
That calculator determined the amount and price of the adjustment, and wrote the adjustment's description and additional metadata, which it stored in the adjustment's `:data` field.
These details may provide enough information to answer the retailer's question about the order's pricing.
When these details are _not_ enough, you'll have to dig deeper to explore _how_ the price adjustment was created.

As the name of the `:calculator` field implies, price adjustments are created by __pricing calculators__.


### Pricing Calculators

_Pricing calculators_ are objects that _adjust_ the pricing of an order transaction by creating price adjustments on the items and shippings during the pricing of the order.
More specifically, each calculator inherits from `Pricing::Calculator` and implements `Pricing::Calculator#adjust`.
This method encapsulates the logic for creating the price adjustments the calculator is responsible for.

During the pricing of an order, each calculator is given the opportunity to adjust the order pricing by writing adjustments to the items and shippings.
This process is managed by `Pricing.perform`, which begins by clearing all price adjustments from the order's items and shippings.
(There is one type of adjustment that isn't cleared, for historical reasons, which is the adjustment that shippings write to themselves, outside of `Pricing.perform`.
These adjustments represent the price of the shipping service for each shipping.)
`Pricing.perform` then calls `#adjust` on each pricing calculator, providing it the opportunity to create price adjustments on the items and shippings.
This process builds the price adjustment stack that you've seen many times above.

The following diagram illustrates this process for our example order.
The order has two items and one shipping.
The example shown represents the final pricing of the order, during the "place order" action.
The pricing process begins with a single price adjustment on the shipping.
Each calculator then has the opportunity to adjust the pricing; some do nothing while other create adjustments (which are highlighted).
The end result is the familiar stack of price adjustments used to calculate the pricing totals.

![Pricing calculators diagram](/images/pricing-calculators-diagram.png)

It's important to understand this overall process because each calculator has access to the adjustments created by the calculators that precede it.
Knowledge of the process therefore helps you understand each calculator's implementation of `#apply`, which are not explained in this document.
Some of these implementations are quite complex and defer to other subsystems, such as discounts and taxes.
Until each of these implementations can be sufficiently documented, you'll need to explore them on your own.

The following command prints the pathnames of all pricing calculators available to your application:

```bash
find $(pwd) $(bundle show --paths | grep workarea) \
-path '*/app/*/pricing/calculators/*.rb'
```

Plugins and applications can also provide their own pricing calculators, which is the basis of __extending order pricing__.


Skill: Extending Order Pricing
----------------------------------------------------------------------

Sometimes, the business requirements of a retailer require you to do more than _explain_ order pricing; you must _extend_ it.
A retailer may add a new feature that affects pricing, such as offering gift wrapping for a fee; or they may want to replace an existing feature, such as using an integrated service to calculate taxes rather than Workarea's default logic.

Fortunately, for requirements such as these, Workarea provides a clear path for extension.
To extend pricing, you must change how price adjustments are created.
To do this, you should implement your own pricing calculators which honor the __pricing calculator contract__, and re-configure the __pricing calculators collection__ to include your custom calculators.

(
It's worth mentioning that you should first look for a plugin that does what you need.
I borrowed this document's use cases from existing plugins.
)


### Pricing Calculator Contract

To create your own pricing calculator, define a class which satisfies the _pricing calculator contract_.
Fundamentally, this is a class which includes `Pricing::Calculator` and implements `Pricing::Calculator#apply`.

(
I'll continue to explain this process conceptually, but for a more detailed, procedural explanation of creating your own pricing calculators, see [Add or Replace a Pricing Calculator](/articles/add-or-replace-a-pricing-calculator.html).
)

`Pricing::Calculator#apply` has access to several objects and collections via the methods `#order`, `#shippings`, `#pricing`, and `#discounts`; and it must satisfy two responsibilities: determine which objects should receive the price adjustments, and create the price adjustments on those objects.

To determine the objects, start with this simple rule: create _item_ and _order_ adjustments on _items_, and create _shipping_ and _tax_ adjustments on _shippings_.
This rule follows the logic of the Core calculators, which write shipping and tax adjustments to shippings because those adjustments require a shipping address to compute.
However, your calculator may need to look for _specific_ items and shippings.
For example, the customizations calculator creates adjustments for only those items that include customizations.
Adjustments to the entire order, say _$50 off your entire order_, must be distributed across the items, since the order has no price adjustments of its own.
Also, the retailer likely wants the cost distributed in the case of a customer returning a single item.

To create the adjustments, use `Order::Item#adjust_pricing` or `Shipping#adjust_pricing`, and provide the following `PriceAdjustment` attributes:

| Attribute      | Description |
| -------------- | ----------- |
| `:amount`      | The money amount which may be displayed and will contribute to pricing totals |
| `:price`       | The type of adjustment, either `'item'`, `'order'`, `'shipping'`, or `'tax'`, which determines to which totals the amount contributes and where it's displayed |
| `:description` | A brief description of the adjustment, which may display directly to shoppers |
| `:calculator`  | The class of your calculator, as a string |
| `:data`        | A hash of additional data for audit and/or implementation purposes; see base calculators for examples |

After creating a calculator that meets these requirements, you must manipulate the __pricing calculators collection__ to include your calculator.


### Pricing Calculators Collection

The _pricing calculators collection_ is a configurable value—a [SwappableList](/articles/swappable-list-data-structure.html)—which holds the ordered list of pricing calculators which can adjust the pricing of orders during each `Pricing.perform`.

In other words, the list of which pricing calculators run, in which order, is configurable.
The following code example queries the current configuration of an application:

```ruby
Workarea.config.pricing_calculators.class
# => Workarea::SwappableList

puts Workarea.config.pricing_calculators
# Workarea::Pricing::Calculators::ItemCalculator
# Workarea::Pricing::Calculators::CustomizationsCalculator
# Workarea::Pricing::Calculators::OverridesCalculator
# Workarea::Pricing::Calculators::DiscountCalculator
# Workarea::Pricing::Calculators::TaxCalculator
```

You must modify this list to include your custom pricing calculator.
Use the methods of [SwappableList](/articles/swappable-list-data-structure.html) to insert your calculator before or after an existing calculator, or to replace an existing calculator.
You should _replace_ a calculator when you want to _change_ how its price adjustments are created, like using a tax service integration to create tax adjustments, rather than Workarea's tax subsystem.
In contrast, _insert_ your calculator to add an _additional_ upcharge for a feature, such as gift wrapping.

When inserting a new calculator, its position in the list is important.
The default calculator order obeys the following logic:

1. Start with a subtotal for each item
2. Add the cost of any customizations (e.g. engraving)
3. Reduce the item or order cost according to order-specific overrides (e.g. a customer service credit)
4. Apply discounts
5. Calculate tax

You should not change the sequence of the default calculators, since they depend on this order.
For example, an item subtotal must be present before an override can reduce its price, and all other prices must be determined before tax can be calculated.
When inserting a new calculator, determine where it fits into this logic.
In most cases, a new calculator is added to create an additional upcharge, and should therefore be inserted after the customizations calculator (which performs a similar function).
However, review the logic above, and determine where your calculator fits.


Summary
----------------------------------------------------------------------

Workarea handles the complication of computing order prices, but you should develop the skills of explaining and extending order pricing.
Both skills depend on a knowledge of Workarea's cycle of commerce, which requires all orders to be continually re-priced until they are placed.

To explain a cart or placed order's pricing, start from one or more pricing totals, which are money fields on the order, items, and shippings.
Deconstruct those fields back into price adjustments, documents embedded in items and shippings that represent the raw pricing data for that order.
To do so, look at the implementations of the pricing totals objects, specifically the `#total` method, which encapsulates the logic to go from adjustments to totals.
Examine the fields of the price adjustments, and attempt to explain the order's pricing from that data.
If insufficient, use the meta data on the price adjustments to identify which pricing calculators created them.
Study the implementation of `#apply` for each calculator to see in more detail how each price was created.

To extend the pricing logic, define your own pricing calculators, each of which must implement an `#apply` method that creates price adjustments on zero or more of the items and shippings that make up an order.
Ensure that each price adjustment has an amount, price, and metadata such as description and calculator.
Include each of your pricing calculators in the configurable pricing calculators collection, either as a new calculator or as a replacement for an existing calculator.
Always preserve the order of the default calculators, while placing new calculators in a logical postion within the collection.
