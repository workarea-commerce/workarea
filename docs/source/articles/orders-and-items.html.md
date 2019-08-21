---
title: Orders & Items
excerpt: Orders are transactions between consumers and the retailer. Consumers create orders in the Storefront, as carts, to which they add items (and optionally promo codes). Consumers complete checkouts, thereby placing their orders. The placed orders, which
---

# Orders & Items

[Orders](orders.html) are transactions between consumers and the retailer. Consumers create orders in the Storefront, as carts, to which they add items (and optionally promo codes). Consumers complete checkouts, thereby placing their orders. The placed orders, which act as permanent records of the transactions, are accessible to the retailer through the Admin.

The `Order` class (which is also a module/namespace) is the primary model representing these transactions. Each order [document](application-document.html) represents an order through its entire life cycle, from cart through order management. An order model therefore fulfills the roles of purchase order, invoice, and detailed receipt for a transaction.

The `Order` model and its embedded items identify the consumer and the items that make up the transaction and their prices. More specifically, a placed order is composed of the following data:

- The identity of the consumer and their environment
- One or more items, each composed of: 
  - A SKU, quantity, and additional details to identify and price the item
  - One or more price adjustments representing granular pricing details
  - The calculated item-level price totals
- Zero or more promo codes, which may affect item and order pricing
- The calculated order-level price totals

## Consumer & Environment

Each order stores information identifying the consumer, who is either a guest, a user, an admin guest browsing, or an admin impersonating a user.

At a minimum, a placed order has an email:

```
order = Workarea::Order.sample
# => #<Workarea::Order _id: 39F628D36D, ... >

order.email
# => "bobbyclams@workarea.com"
```

An order may have additional contextual information, such as the consumer’s IP address and an order _source_, such as `'storefront'`, `'admin'`, or `'api'`:

```
order.ip_address
# => "127.0.0.1"

order.source
# => "storefront"
```

Orders placed by users, admins impersonating users, and admins guest browsing will additionally store the IDs of both users as the `user_id` and `checkout_by_id`. These values are foreign keys that relate the order to `User` models. Similarly, orders placed through a web browser store the `user_activity_id`, which relates the order to a `UserActivity` model<sup><a href="#notes" id="note-1-context">[1]</a></sup>.

```
order.user_id
# => "5ab2b5b3eefbfe12dbb4b44b"

order.user_activity_id
# => "5ab2b5b3eefbfe12dbb4b44b"

order.checkout_by_id
# => "5ab2b5b3eefbfe12dbb4b44b"
```

Additional details about the consumer, such as name and shipping and billing addresses, are stored on other models and are not a concern of the `Order` model.

## Items

Each order contains _items_, an embedded collection of type `Order::Item`.

```
order.items.count
# => 2

order.items.first.class
# => Workarea::Order::Item
```

Each item document contains the data the retailer needs to fulfill the item (SKU, quantity, and customizations), additional data to calculate the price(s) of the item (SKU details), and records of the actual prices calculated (price adjustments and item totals).

### SKU, Quantity & Details

Each item represents a good or service from the retailer’s catalog, identified by its _SKU_. Typically, the SKU and quantity provide the minimum data required to fulfill the item. However, some items allow customization by the consumer (for example engraving or monogramming), in which case additional data is collected to perform the customization during fulfillment.

```
item = order.items.first
# => #<Workarea::Order::Item _id: 5ab2b5eceefbfe12dbb4b451, ... >

item.sku
# => "524376751-4"

item.quantity
# => 1

item.customizations
# => {}
```

In most cases, additional details are saved on the item to ensure the item is priced accurately. The pricing subsystem uses a series of calculators to determine the total price of each item and the order overall. These calculators often depend on the additional item details to calculate pricing as expected. These details include the product ID and attributes (the entire product model, serialized), the categories in which the product appears, and whether the item is discountable.

```
item.product_id
# => "66BC7BEA53"

pp item.product_attributes.keys
# ["_id",
# "tags",
# "active",
# "subscribed_user_ids",
# "details",
# "filters",
# "template",
# "purchasable",
# "name",
# "digital",
# "description",
# "slug",
# "updated_at",
# "created_at",
# "variants"]

pp item.category_ids
# ["5ab2b04beefbfe1185011c9d",
# "5ab2b04beefbfe1185011c9f",
# "5ab2b04beefbfe1185011c9b"]

item.discountable
# => true
```

The forthcoming guide, “Managing Carts”, will describe API calls for fetching these details and storing them on the order item.

### Price Adjustments

Each time an order is priced, the granular pricing details are stored on the item as _price adjustments_, an embedded collection of type `Workarea::PriceAdjustment`. These embedded documents provide the necessary details to determine the total price of an item (in the case of a cart) and a record of how that price was determined (in the case of a placed order).

```
item.price_adjustments.count
# => 2

price_adjustment = item.price_adjustments.last
# => #<Workarea::PriceAdjustment _id: 5ab2b0a2eefbfe11850123f2, ... >

price_adjustment.amount.to_f
# => -8.32

price_adjustment.description
# => "10% Off Order"
```

Item pricing is volatile; prices fluctuate and vary based on quantity, sales, discounts, and other factors. The unit price of an item and the adjustments that may apply due to active discounts and other factors are likely to change from order to order, and may even change within the lifespan of a single cart. Therefore, each order is continually re-priced until it is placed.

While the details of order pricing and price adjustments are outside the scope of this guide, one detail is notable here: order items and [shippings](shipping.html) are the only models that embed price adjustments. All _order_ and _item_ adjustments are stored on an order’s _items_, while all _shipping_ and _tax_ adjustments are stored on the _shippings_ related to the order.

### Item Totals

Additionally, each time an order is priced, the total price and value<sup><a href="#notes" id="note-2-context">[2]</a></sup> of each item are written onto the item as fields. These values provide a snapshot of the “agreed upon” price of the item, as calculated by the pricing module. The consumer can metaphorically “negotiate” this price by shopping at a different time (during a sale or promotion) or applying promo codes to the order.

In the case of a cart, these values may change before the order is placed. The values are displayed to the consumer when viewing the cart and throughout checkout. In the case of a placed order, these represent the price at which the item sold, which may differ for another consumer purchasing the same item or the same consumer when placing a different order.

```
item.total_price.to_f
# => 83.24

item.total_value.to_f
# => 74.92
```

## Promo Codes

Returning to the order, in addition to items, consumers can add promo codes, which may qualify the order or its items for discounts, resulting in more favorable pricing for the consumer. Unlike items, which are embedded documents, promo codes are simply strings stored in an array on the order.

```
order.promo_codes
# => ["10PERCENTOFF"]
```

The order model provides API calls to add promo codes, which ensure the collection contains only unique, uppercase string values. The forthcoming “Managing Carts” guide will cover this topic.

## Order Totals

Similarly to item totals, when the pricing module prices an order, it writes the order-level totals to the order as fields. For a cart, these values represent the last calculated “asking price” of the order, and for a placed order they represent the final transaction prices. The Storefront displays these values in the cart and checkout for the consumer, and the Admin displays these values to the retailer in the order administration screens and reports.

```
order.subtotal_price.to_f
=> 153.23

order.shipping_total.to_f
=> 7.0

order.tax_total.to_f
=> 10.14

order.total_price.to_f
=> 155.05

order.total_value.to_f
=> 137.91
```

While the full details of pricing are outside the scope of this guide, note that subtotal price is derived from the price adjustments stored on the _items_, while the shipping and tax totals are derived from the price adjustments stored on the related _shippings_.

## Summary

- Orders build and record consumer/retailer transactions, which contain the consumer’s identity, the items being transacted, and the “current” pricing as calculated by the pricing subsystem
- Each item on an order contains the SKU and quantity, along with other details to accurately price the item
- Consumers can add promo codes to the order, which may also affect pricing
- Pricing is recorded on each item as granular price adjustments and calculated item-level totals, and on the order as calculated order-level totals

## Notes

[1] User activity is an aspect of the Workarea recommendations subsystem that will be covered in more detail in future documentation.

[2] Upcoming pricing documentation will describe the concept of price vs value.


