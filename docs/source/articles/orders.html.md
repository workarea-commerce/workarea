---
title: Orders
created_at: 2018/07/31
excerpt: 'Workarea applications facilitate orders: transactions between consumers and retailers. Due to their complexity, orders are enabled by and recorded across many models within the Workarea platform. More specifically, various models within the Order, Shi'
---

# Orders

Workarea applications facilitate <dfn>orders</dfn>: transactions between consumers and retailers. Due to their complexity, orders are enabled by and recorded across many models within the Workarea platform. More specifically, various models within the `Order`, `Shipping`, `Payment`, `Pricing`, `Inventory`, and `Fulfillment` modules enable and record these transactions.

However, at the core of each of these transactions is an `Order` model. The order model uniquely identifies the transaction, and using its `id`, you can join the various models, providing a complete record of the transaction.

## Seeding Order Data

Workarea provides [seeds](/articles/seeds.html) for orders, which are defined in `Workarea::OrdersSeeds`. This seeds script creates a variety of placed orders, as well as the user, shipping, and payment data needed to place those orders.

Each order is placed through <dfn>checkout</dfn>, a process that joins an order with the other models necessary to represent a complete consumer/retailer transaction.

Finally, the script _fulfills_ each order, which involves capturing the associated payment and marking the items shipped.

## Joining Order Data

Using the first seeded order as its subject, the following example demonstrates how you can join an order model with the corresponding shippings, payment, inventory transactions, and fulfillment. In practice, this sort of in-application join is typically performed in a [view model](/articles/view-models.html).

```
order = Workarea::Order.first

shippings = Workarea::Shipping.where(order_id: order.id).to_a
# => [#<Workarea::Shipping _id: 5a95ab0707dd423bb63a92d0, ...>]

payment = Workarea::Payment.find(order.id)
# => #<Workarea::Payment _id: 048E031F8B, ...>

inventory_transactions =
  Workarea::Inventory::Transaction.where(order_id: order.id).to_a
# => [#<Workarea::Inventory::Transaction _id: 5a95ab0a07dd423bb63a931, ...>]

fulfillment = Workarea::Fulfillment.find(order.id)
# => #<Workarea::Fulfillment _id: 048E031F8B, ...>
```

## The Order Module

As you can see in the example above, the `id` of the Order model is what relates the various models. Central to order modeling is the `Order` module and its primary models: `Order` and `Order::Item`.

The following order module topics are pertinent to Workarea application and plugin developers:

- [The _order_ and _order item_ abstractions](/articles/orders-and-items.html)
  - What they represent
  - How they are structured
- Order statuses and states
- Managing carts
- Indexing and searching for orders
- Managing placed orders
- Exporting orders
- Canceling orders
- Copying orders
- Order reporting and insights
- Extending orders

## Summary

- Orders are transactions between consumers and retailers, which are represented by various models within the Workarea platform
- The model central to a consumer/retailer transaction is `Order`; its `id` joins the other models
- The platform provides seeds to bootstrap an environment with placed orders
- Forthcoming guides will explain the order and item abstractions and the various uses of orders within the platform

