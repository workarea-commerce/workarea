---
title: Order Life Cycle
created_at: 2018/08/07
excerpt: 'Order models represent order transactions throughout their entire life cycles, thereby encapsulating the function of several traditional business documents (for example: purchase order, invoice, and receipt) into a single document.'
---

# Order Life Cycle

`Order` models represent [order transactions](/articles/orders.html) throughout their entire life cycles, thereby encapsulating the function of several traditional business documents (for example: purchase order, invoice, and receipt) into a single document.

Orders begin their lives driven largely by consumers. Consumers create carts, which ideally progress through checkout, but may become abandoned along the way. If not placed, orders eventually expire and are cleaned. In an effort to prevent this, abandoned orders trigger reminders to consumers, which may result in resumed carts and checkouts.

Completed checkouts result in placed orders, which unlike carts, are handled primarily by the retailer. Placed orders are indexed into search, through which admins access and manage the orders. Placed orders are permanent records that never become abandoned or expire, even when they are canceled.

Since Workarea 3.5, orders can also be suspected of fraud, and such orders are additionally indexed into Admin search.

This guide describes the preceding domain concepts in greater detail, providing as examples all the configurable values and aspects of the `Order` interface that effectively define this domain logic and affect the progression of an order through it’s various statuses and states.

Copious examples use the Ruby interface provided by Workarea Core. Each example builds on those before it, as if run sequentially within the same Ruby process.

## Carts

Orders begin as <dfn>carts</dfn>, typically created by consumers in the Storefront. The cart status is the default state of an order, generally defined as “not in any other status”.

```
order = Workarea::Order.create

order.status
# => :cart
```

Carts, like other [application documents](/articles/application-document.html), have timestamps which encode the date and time at which they were created and last updated. Later examples show uses of these timestamps.

```
order.created_at.present?
# => true

order.updated_at.present?
# => true
```

In a broader sense, carts include all orders that aren’t placed, as demonstrated in the following examples:

```
Workarea::Order.carts.include?(order)
# => true

order.placed_at.present?
# => false

order.placed?
# => false

Workarea::Order.not_placed.include?(order)
# => true
```

## Abandoned Carts

Orders not placed within the configurable `order_active_period` are considered <dfn>abandoned</dfn>. The order created above is not abandoned because its `created_at` is still within the order active period.

```
Workarea.config.order_active_period
# => 2 hours

order.abandoned?
# => false

order.created_at > Workarea.config.order_active_period.ago
# => true
```

The following example uses Rails’ [testing time helpers](http://api.rubyonrails.org/v5.1/classes/ActiveSupport/Testing/TimeHelpers.html) to simulate the passage of time, demonstrating the effect on the order’s status. After the active period has passed, the order identifies as abandoned.

```
include ActiveSupport::Testing::TimeHelpers

travel Workarea.config.order_active_period

order.created_at > Workarea.config.order_active_period.ago
# => false

order.abandoned?
# => true

order.status
# => :abandoned
```

### Order Expiration

Furthermore, orders that go unmodified within the configurable `order_expiration_period` are considered <dfn>expired</dfn>. The following example queries for expired orders before and after the expiration period has elapsed.

```
Workarea.config.order_expiration_period
# => 6 months

Workarea::Order.expired.include?(order)
# => false

order.updated_at > Workarea.config.order_expiration_period.ago
# => true

travel Workarea.config.order_expiration_period

order.updated_at > Workarea.config.order_expiration_period.ago
# => false

Workarea::Order.expired.include?(order)
# => true
```

### Cleaning Orders

Workarea applications run a [scheduled worker](/articles/workers.html#sidekiq-cron-job) to periodically clean up (that is, destroy) expired orders. Manually running this worker removes the order from the database.

```
Workarea::CleanOrders.new.perform

Workarea::Order.expired.include?(order)
# => false

Workarea::Order.all.include?(order)
# => false
```

## Checkouts

<dfn>Checkouts</dfn> are carts in the process of checking out. Checkout is the process used to transition an order from a cart to a placed order. The following examples require a new order

```
order = Workarea::Order.create
```

which embeds an item. This example assumes catalog data is already seeded.

( The following procedure for adding an item is suitable for demonstration but not ideal for production use. For the latter, review the implementation of `Storefront::CartItemsController#create` ([source, v3.4.17](https://github.com/workarea-commerce/workarea/blob/v3.4.17/storefront/app/controllers/workarea/storefront/cart_items_controller.rb#L13). )

```
product = Workarea::Catalog::Product.sample

order.add_item(
  product_id: product.id,
  sku: product.variants.first.sku,
  quantity: 1
)
```

Creating and starting a checkout writes a new timestamp to the order, recording the time checkout was started. The presence of this timestamp causes the order to identify as a checkout.

```
checkout = Workarea::Checkout.new(order)

checkout.start_as(:guest)

order.checkout_started_at.present?
# => true

order.started_checkout?
# => true

order.checking_out?
# => true

order.status
# => :checkout
```

However, because the order is not yet placed, it also identifies as a cart.

```
Workarea::Order.carts.include?(order)
# => true

Workarea::Order.not_placed.include?(order)
# => true
```

### Checkout Expiration

If a checkout idles beyond the configurable duration, `checkout_expiration`, the checkout expires. In this case, the order is returned to the cart status, and the consumer must restart checkout.

```
Workarea.config.checkout_expiration
# => 15 minutes

order.checkout_started_at > Workarea.config.checkout_expiration.ago
# => true

order.status
# => :checkout

travel Workarea.config.checkout_expiration

order.checkout_started_at > Workarea.config.checkout_expiration.ago
# => false

order.checking_out?
# => false

order.status
# => :cart
```

This does not mean the consumer must complete the entire checkout within this period, since each Storefront checkout request <dfn>touches</dfn> the checkout, updating the checkout start time (along with some other details). This prevents the checkout from expiring and will also “revive” an expired checkout, returning it to active checkout status.

```
order.touch_checkout!

order.checkout_started_at > Workarea.config.checkout_expiration.ago
# => true

order.checking_out?
# => true

order.status
# => :checkout
```

## Abandoned Checkouts

As with all carts, a checkout that is not placed within the order active period is considered abandoned. Traveling forward this duration expires the checkout and causes the order to become abandoned.

```
travel Workarea.config.order_active_period

order.checkout?
# => false

order.abandoned?
# => true

order.status
# => :abandoned
```

However, while the order is actively checking out, it will not identify as abandoned, despite it existing longer than the order active period.

```
order.touch_checkout!

order.checking_out?
# => true

order.abandoned?
# => false
```

After the checkout expires, the order returns to abandoned status.

```
travel Workarea.config.checkout_expiration

order.checking_out?
# => false

order.abandoned?
# => true

order.status
# => :abandoned
```

### Order Reminding

To help recover the potentially lost revenue of abandoned orders, Workarea applications send “reminder” emails when possible. Each email contains a token allowing the consumer to resume the cart.

For an order to be considered <dfn>needs reminding</dfn>, it must have started checkout, become abandoned, and have an email. Since Workarea 3.5, it must also not be suspected of fraud (see section [Suspected Fraud](#suspected-fraud) below).

The example order does not qualify because it is an active checkout and does not have an email.

```
order.checking_out?
# => true

order.email.present?
# => false

Workarea::Order.need_reminding.include?(order)
# => false
```

Expiring the checkout (by simulating the passage of time) and adding an email causes the order to match.

```
travel Workarea.config.checkout_expiration

order.update_attributes(email: 'bobbyclams@workarea.com')

Workarea::Order.need_reminding.include?(order)
# => true
```

A scheduled worker runs this query periodically and sends a reminder email for each matching order. Each order is “marked as reminded” with a `reminded_at` timestamp, which prevents the order from matching the query again.

```
Workarea::OrderReminder.new.perform

order.mark_as_reminded!

order.reminded_at.present?
# => true

Workarea::Order.need_reminding.include?(order)
# => false
```

### Order Expiration After Starting Checkout

If the reminder email does not entice the consumer to resume the cart, the order will likely expire and be cleaned. Notice in the following example the order is returned only by `Order.expired_in_checkout`, which was added in Workarea 3.3 to address the issue of orders never expiring after starting checkout.

( In Workarea versions prior to 3.3, this order will never expire unless checkout is explicitly reset, and the order is therefore never cleaned. )

```
travel Workarea.config.order_expiration_period

order.updated_at <= Workarea.config.order_expiration_period.ago
# => true

order.started_checkout?
# => true

Workarea::Order.expired.include?(order)
# => false

Workarea::Order.expired_in_checkout.include?(order)
# => true
```

### Resetting Checkout

One final note regarding checkout: it is possible to explicitly <dfn>reset</dfn> a checkout, which returns the order to the cart status and removes any record of checkout having started.

```
order.reset_checkout!

order.checkout_started_at.present?
# => false

order.started_checkout?
# => false
```

Now the order will _not_ be reminded since it has no record of starting checkout.

```
Workarea::Order.need_reminding.include?(order)
# => false
```

Resetting checkout also removes the `reminded_at` timestamp, so the order will qualify as _needs reminding_ if checkout if resumed.

```
order.reminded_at.present?
# => false

order.touch_checkout!

travel Workarea.config.order_active_period

Workarea::Order.need_reminding.include?(order)
# => true
```

## Placed Orders

Checkout concludes by <dfn>placing</dfn> the order. Always place an order through checkout, not directly from the order. This ensures the completion of each checkout step, manages inventory, creates the corresponding `Fulfillment`, and saves order analytics.

However, placing the example order through checkout fails because the checkout steps are incomplete. To continue demonstrating the placed order status without distraction, the following example places the order directly from the order model.

```
checkout.place_order
# => false

order.place
# => true
```

The `place` method does little more than set the `placed_at` timestamp and save the order. However, it saves the order conservatively, waiting for the save to write to disk and (in hosted environments) replicate to other nodes before reporting success.

( The `Order#place` method also runs the custom `:place` callback (see [Callbacks Worker](/articles/workers.html#callbacks-worker), which enqueues additional work to run in the background. However, those jobs are outside the scope of the `Order` module and are not covered here. )

```
order.placed_at.present?
# => true
```

This addition causes the order to identify as placed.

```
order.placed?
# => true

order.status
# => :placed

Workarea::Order.placed.include?(order)
# => true

Workarea::Order.recent_placed.include?(order)
# => true
```

Moreover, the order no longer identifies as a cart, since the cart and placed statuses are exclusive.

```
Workarea::Order.carts.include?(order)
# => false

Workarea::Order.not_placed.include?(order)
# => false
```

As a placed order, the order can no longer be abandoned or expire.

```
travel Workarea.config.order_expiration_period

order.status
# => :placed

order.abandoned?
# => false

Workarea::Order.expired.include?(order)
# => false
```

### Creating Placed Orders with Factories

Setting up the necessary data to complete an order properly through checkout is cumbersome (hence, the process was skipped above). However, in a testing context, factories make it easier to create orders, including placed orders.

Requiring the application’s test helper and including the factories module enables factories in the current Ruby process (this isn’t necessary when writing code within a test case).

```
# WARNING: drops the database for the current Rails environment!
require_relative 'test/test_helper'

include Workarea::Factories

cart = create_order

placed_order = create_placed_order

cart.status
# => :cart

placed_order.status
# => :placed
```

You can also use `complete_checkout` to place an order you've already created. The existing order must have an email and at least one item. The factory creates the shipping and payment data needed to complete checkout, and places the order.

```
order = create_order

order.status
# => :cart

complete_checkout(order)
# => true

order.status
# => :placed
```

### Searching Placed Orders

Notably, search has been absent from this discussion so far. This is due to the fact that only _placed_ orders are indexed into Elasticsearch, in order for administrators to manage the placed orders through the Admin interface. (This changes in Workarea 3.5, which introduces fraud analysis. Orders suspected of fraud are also indexed into Admin search. See section [Suspected Fraud](#suspected-fraud) below.)

The next example first resets the Admin search indexes and then manually indexes the cart and placed order which were created above. Only the placed order is returned in search results.

```
cart = create_order

placed_order = create_placed_order

Workarea::Search::Admin.reset_indexes!

Workarea::Search::AdminOrders.new.results.count
# => 0

Workarea::IndexAdminSearch.perform(cart)

Workarea::IndexAdminSearch.perform(placed_order)

Workarea::Search::AdminOrders.new.results.count
# => 1

Workarea::Search::AdminOrders.new.results.first.id == placed_order.id
# => true
```

## Canceled Orders

Workarea Core also allows <dfn>canceling</dfn> orders, however, this does not take into consideration the restocking of inventory, refunding of payment, and updating of fulfillment that may accompany such a change. Because of these additional concerns, this functionality is not exposed as a web interface in the base platform, but is available through the _Workarea OMS_ plugin.

From the `Order` document’s perspective, <dfn>canceling</dfn> an order (achieved through `Order#cancel`) is simply the process of recording the date and time at which the order was canceled. The presence of this additional timestamp causes the order to identify as canceled.

```
placed_order.cancel
# => true

placed_order.canceled_at.present?
# => true

placed_order.canceled?
# => true

placed_order.status
# => :canceled
```

A canceled order also continues to identify as a placed order and continues to be accessible through search.

```
placed_order.placed_at.present?
# => true

placed_order.placed?
# => true

Workarea::Order.placed.include?(placed_order)
# => true

Workarea::Order.recent_placed.include?(placed_order)
# => true

Workarea::Search::AdminOrders.new.results.first.id == placed_order.id
# => true
```


## Suspected Fraud

Workarea 3.5 adds fraud analysis, and therefore introduces an additional order status: _suspected fraud_.

The API call `Order#set_fraud_decision!` embeds the given `Order::FraudDecision` within the order and sets one or both of the timestamps `:fraud_decided_at` and `fraud_suspected_at`. When the fraud decision is declined, the query `#fraud_suspected?` returns `true`, and the order's status is `:suspected_fraud`.

```ruby
order.set_fraud_decision!(declined_decision)

order.fraud_decision.class
# => Workarea::Order::FraudDecision

order.fraud_decided_at.present?
# => true
order.fraud_suspected_at.present?
# => true

order.fraud_suspected?
# => true

order.status
# => :suspected_fraud
```

Additionally, orders suspected of fraud are indexed into Admin Elasticsearch indexes.

See [Add a Fraud Analyzer](/articles/add-a-fraud-analyzer.html) for more coverage of fraud analysis.


## Summary

Consumers create carts in the Storefront, which may become abandoned and expire, and are eventually cleaned.
Carts progress through checkouts, which also expire and may become abandoned.
Abandoned orders are reported and (when possible) reminded, which may result in resumed carts and checkouts.
Completed checkouts produce placed orders, which are indexed into search for management by admins, and may be canceled.
Since Workarea 3.5, orders may also be suspected of fraud, and such orders are additionally indexed into Admin search.

These order statuses and states are defined largely by aspects of the `Order` interface, namely: 

* The `status` instance method
* The destructive instance methods `touch_checkout!`, `reset_checkout!`, `mark_as_reminded!`, `place`, `cancel`, and `set_fraud_decision!`
* The timestamp fields `created_at`, `updated_at`, `checkout_started_at`, `reminded_at`, `placed_at`, `canceled_at`, and `fraud_suspected_at`
* The predicate methods `abandoned?`, `started_checkout?`, `checking_out?`, `placed?`, `canceled?`, and `fraud_suspected?`
* The criteria class methods `.carts`, `.not_placed`, `.expired`, `.need_reminding`, `.placed`, and `.recent_placed`

as well as the configurable durations `Workarea.config.order_active_period`, `Workarea.config.order_expiration_period`, and `Workarea.config.checkout_expiration`.
