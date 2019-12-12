---
title: Inventory
excerpt: Workarea includes an inventory subsystem providing inventory management and automated merchandising, which developers can extend
---

Inventory
======================================================================

Workarea includes an inventory subsystem providing inventory management and automated merchandising based on inventory levels and policies.
This system is fully functional as it is, but developers may need to extend or operate the system to accomplish the following:

* Integrate Workarea with a retailer's inventory management system
* Define and configure inventory policies
* Explain to a retailer how the inventory system works, including inventory management and inventory's effects on the shopping experience (for example, you may need to explain how an item's inventory is preventing a product from matching a search)

To develop these skills, you'll need to know the following:

* How retailers manage inventory within Workarea
* How Workarea protects retailers by not overselling, while also maintaining the quality of the shopping experience for shoppers
* How Workarea captures and releases inventory when shoppers place and cancel orders, which maintains inventory integrity

This document therefore describes the Workarea inventory system, from management to reporting.

A retailer manages __inventory SKUs__, each of which has __administrable fields__, including a __policy__, from which Workarea derives various __inventory SKU states__.
Workarea uses these states to prevent overselling and to communicate availability when presenting searches, categories, recommendations, products, and carts.
Finally, when shoppers place and cancel orders, Workarea __purchases__, __captures__, and __releases__ inventory, managing the same inventory fields as retailers.
Workarea records these __inventory transactions__ for each order and also provides reports and insights to help a retailer restock inventory effectively.


Inventory Management
----------------------------------------------------------------------

A retailer can manage inventory within Workarea directly or within a separate inventory management system that is integrated with Workarea.
( Regarding the latter, see [Integrate an Inventory Management System](/articles/integrate-an-inventory-management-system.html). )
In either case, the retailer manages inventory via several administrable fields on inventory SKUs.


### Inventory SKUs

An _inventory SKU_ is a MongoDB-backed model representing the inventory for an item in the retailer's catalog.
Each inventory SKU is identified by the item's SKU, a retailer-specific ID that relates the inventory SKU to other models representing the same item within Workarea.
( See [Products](/articles/products.html) for a more thorough explanation of the models that represent merchandise, and their relationships. )

Administrators, developers, and automated systems manage inventory by manipulating several administrable fields on each inventory SKU, including the inventory SKU's policy.


### Administrable Fields & Policies

The following table describes the _administrable fields_ of each inventory SKU:

| Field | Description |
| ----- | ----------- |
| `:available` | The integer count of units that are available except when reserved; defaults to `0` |
| `:backordered` | The integer count of units that are available when backorder is allowed, except when reserved, defaults to `0` |
| `:reserve` | The integer count of units to reserve from the collective pool of `available` and `backordered`; defaults to `0` |
| `:backordered_until` | The `Time` at which backordered units are expected to move to available |
| `:policy` | A string identifying one of the policies enumerated in `Workarea.config.inventory_policies`; defaults to the first policy in that configurable collection |

The most important of these fields are the integer values `:available`, `:backordered` and `reserve`, and the `:policy`, which Workarea uses collectively to derive various inventory states, as explained in the following sections.


Presenting Products & Carts
----------------------------------------------------------------------

While the retailer is responsible for setting the inventory values in the above fields, Workarea is responsible for honoring those values throughout the shopping experience.
Workarea must prevent overselling to protect the retailer, and must also maintain the user experience for shoppers.
To accomplish both goals, Workarea performs automatic merchandising which prevents shoppers from adding unavailable items to their carts, or may hide items from shoppers altogether while inventory is unavailable.
This requires determining the displayability and purchasability of each item, based on its inventory.
Workarea derives these states from the administrable fields on the inventory SKU.


### Inventory Policies & SKU States

Introduced above, an _inventory policy_ is a class of object that declares the logic for converting the administrable values of an inventory SKU into _inventory SKU states_.
An inventory policy also declares the logic for purchasing a SKU's inventory, which is covered below.

Workarea includes several inventory policies, and plugins and applications can define and configure their own policies.
( For a more in-depth look at policy class definitions and configuration, see [Define & Configure Inventory Policies](/articles/define-and-configure-inventory-policies.html). )
The following example enumerates the available policies:

```ruby
puts Workarea.config.inventory_policies
# Workarea::Inventory::Policies::Ignore
# Workarea::Inventory::Policies::Standard
# Workarea::Inventory::Policies::DisplayableWhenOutOfStock
# Workarea::Inventory::Policies::AllowBackorder
```

For each inventory SKU, workarea uses the SKU's policy and other values of its administrable fields to derive the following inventory SKU states:

| State | Description |
| ----- | ----------- |
| `available_to_sell` | The computed integer count of available units, derived from `:available`, `:backordered`, and `reserve` by the policy |
| `purchasable?(quantity)` | Whether the item is purchasable, determined by comparing the given quantity to `available_to_sell`; quantity defaults to `1` |
| `displayable?` | Whether the item is displayable, as determined by the policy |
| `backordered?` | Whether the item is backordered, which can be true only when the policy is `'allow_backorder'` |

The following sections explain each inventory policy and its effects on these inventory SKU states.


#### Standard

The standard policy allows purchase only from the `:available` units, minus those in `:reserve`.
An item is displayable if it is purchasable.

```ruby
# create an inventory SKU
sku = 'WIZRDRPG-5ED'
inventory_sku = Workarea::Inventory::Sku.create(
                  _id: sku,
                  policy: 'standard',
                  available: 0,
                  backordered: 3,
                  reserve: 1
                )

# review the administrable values
inventory_sku.available
# => 0
inventory_sku.backordered
# => 3
inventory_sku.reserve
# => 1

# there are none available to sell, because this policy
# does not allow purchase from :backordered
inventory_sku.available_to_sell
# => 0

# The item is therefore not purchasable and not displayable
inventory_sku.purchasable?
# => false
inventory_sku.displayable?
# => false

# And it is not considered backordered
inventory_sku.backordered?
# => false
```


#### Allow Backorder

When backorder is allowed, units from `:backordered` are additionally available for purchase, minus those in `:reserve`.

```ruby
# change the inventory SKU's policy and re-initialize it
# (to clear the memoized policy object)
inventory_sku.update_attribute(:policy, 'allow_backorder')
inventory_sku = Workarea::Inventory::Sku.find(sku)

# the administrable values haven't changed
inventory_sku.available
# => 0
inventory_sku.backordered
# => 3
inventory_sku.reserve
# => 1

# But the item is now considered backordered
inventory_sku.backordered?
# => true

# And there are units to sell
inventory_sku.available_to_sell
# => 2

# Up to 2 units are purchasable; the 3rd is reserved
inventory_sku.purchasable?
# => true
inventory_sku.purchasable?(2)
# => true
inventory_sku.purchasable?(3)
# => false

# And the item is displayable
inventory_sku.displayable?
# => true
```


#### Displayable When Out of Stock

An item that is displayable when out of stock behaves like a standard item, except it remains displayable when not purchasable.

```ruby
# Change the policy and re-init the inventory SKU
inventory_sku.update_attribute(:policy, 'displayable_when_out_of_stock')
inventory_sku = Workarea::Inventory::Sku.find(sku)

# No changes to the administrable values
inventory_sku.available
# => 0
inventory_sku.backordered
# => 3
inventory_sku.reserve
# => 1

# This policy does not allow backorder
inventory_sku.backordered?
# => false

# So there are therefore none to sell, and
# the item is not purchasable
inventory_sku.available_to_sell
# => 0
inventory_sku.purchasable?
# => false

# However, it is displayable
inventory_sku.displayable?
# => true
```


#### Ignore

Ignoring inventory can be useful for intangible items, such as gift cards, that have effectively infinite inventory.
A retailer may also use this policy if they are not concerned with tracking inventory within Workarea.
This is the default inventory policy.

```ruby
# Change the policy and re-init the inventory SKU
inventory_sku.update_attribute(:policy, 'ignore')
inventory_sku = Workarea::Inventory::Sku.find(sku)

# Administrable values are the same
inventory_sku.available
# => 0
inventory_sku.backordered
# => 3
inventory_sku.reserve
# => 1

# The item is not backordered
inventory_sku.backordered?
# => false

# But there are effectively infinite units available
# (This value will not change, even as orders with this item are placed)
inventory_sku.available_to_sell
# => 99999

# The item is therefore always purchasable and displayable
inventory_sku.purchasable?
# => true
inventory_sku.displayable?
# => true
```


### Searches, Categories & Recommendations

Workarea presents the items of the retailer's catalog as [products](/articles/products.html), which are (generally small) collections of items that share a name, description, and some details, while varying on other details (such as color, size, etc).
When a product document is indexed into Elasticsearch, it contains inventory information from all the items that make up the product.

[Storefront search features](/articles/storefront-search-features.html), such as searches, categories, and product recommendations, take inventory into account when deciding which products match and how they are sorted in results.
The inventory-related display logic can be summarized as follows:

* To match a search or category, a product must have at least one displayable SKU
* To match a query for search-based recommendations, a product must have at least one purchasable SKU
* When sorted by relevance (as opposed to a user-defined sort), search and category results sort products with at least one purchasable SKU above those without a purchasable SKU (unless the product is featured; featured products sort to the top)

Search features essentially re-implement the concepts of displayable and purchasable using inventory fields within product search documents and with queries defined with the Elasticsearch query DSL.
__These determinations can therefore be "stale" relative to the current inventory values in MongoDB__.

A retailer can use inventory policies to determine how products should appear in the results for search-based features.
It may be desirable for an item to be included in results even when it is not purchasable, but Workarea will de-prioritize the product within the results.

The purpose of these presentation rules is to prevent shoppers from adding to their cart items that are not purchasable, which would create a poor user experience for the shopper.


### Products & Carts

While searching and browsing products, a shopper will often select a specific product to view in detail.
The product detail page (PDP), like the search features, reflects the inventory of the items that make up the product.

A PDP presents product options that the shopper selects to narrow the product to a specific item to be added to the shopper's cart.
The product options are derived from the details of the product's displayable SKUs, hence, retailers can use inventory policies to determine which options should display.
For example, an item with only backordered inventory is considered displayable when the SKU's policy is `AllowBackorder`, but not when the policy is `Standard`.

Furthermore, after narrowing to a specific item, the shopper can add the item to the cart only if it is purchasable.
To continue the previous example, an item with only backordered inventory can be added to the cart only if its policy is `AllowBackorder` or `Ignore`.

As with the search features, these rules on the PDP are intended to keep non-purchasable items out of shoppers carts.
However, after a shopper adds an item to their cart, it can become non-purchasable if other shoppers purchase the remaining inventory first (or inventory changes due to inventory management).
Workarea therefore checks inventory on most cart and checkout requests to ensure the items in the cart are still purchasable.
If items become non-purchasable, Workarea removes them from the cart and notifies the shopper.


### Inventory Status Messages

To more directly communicate an item's availability to shoppers, Workarea displays _inventory status messages_ on the PDP and in the cart.
The messages are per-item, so on the PDP a shopper must first narrow the product to a specific item before being shown the inventory status.

The inventory status shown is one of the following:

* In Stock
* _Number_ Left
* Ships on _Date_
* Backordered
* Out of Stock

These messages are for display only, and their logic is therefore encapsulated in a [view model](/articles/view-models.html): `Storefront::InventoryStatusViewModel`.
Review the implementation of that view model in your Workarea version to see the logic for each status.


### Inventory Collection Status

Since Workarea 3.5, the implementation of the messages described above depends on `Inventory::Collection#status`.
This is an additional layer of inventory status added in Workarea 3.5 that provides a status for a collection of one or more inventory SKUs.
This API call depends on [inventory SKU states](#inventory-policies-amp-sku-states) and is used to implement [inventory status messages](#inventory-status-messages), thus sitting in a new layer in between.

To utilize this in your own code, initialize an inventory collection. Then query the status, or query for a specific status:

```ruby
sample_skus = Workarea::Inventory::Sku.sample(10)
collection = Workarea::Inventory::Collection.new(sample_skus)

collection.status
# => :available

collection.available?
# => true
collection.backordered?
# => false
collection.low_inventory?
# => false
collection.out_of_stock?
# => false
```

The list of statuses is determined by a configurable collection (SwappableList) of inventory status calculators: `Workarea.config.inventory_status_calculators`.

```ruby
puts Workarea.config.inventory_status_calculators
# Workarea::Inventory::CollectionStatus::Backordered
# Workarea::Inventory::CollectionStatus::LowInventory
# Workarea::Inventory::CollectionStatus::OutOfStock
# Workarea::Inventory::CollectionStatus::Available
```

You can manipulate this collection, including adding your own statuses.


Placing & Canceling Orders
----------------------------------------------------------------------

You've seen above how Workarea prevents the sale of non-purchasable merchandise.
However, as shoppers place orders, Workarea must maintain accurate inventory levels.
Workarea uses inventory transactions to purchase and release inventory as users place and cancel orders.
Furthermore, Workarea exposes these inventory changes in the Admin through reports and insights.


### Purchasing, Capturing & Releasing Inventory

To maintain accurate inventory within its boundaries, Workarea must _purchase_ the inventory for an order, according to the inventory policy of each SKU.

Regardless of policy, the value of `:purchased` on the inventory SKU is incremented by the quantity purchased.
This value tracks the number of units purchased since the creation of the inventory SKU.
Additionally, the current computed value from `#available_to_sell` is persisted to the field `:sellable`, which is used for presenting a low inventory report.

Depending on policy, units are _captured_ from `:available` and `:backordered`, as described in the following table:

| Policy | Capture Logic |
| ------ | ------------- |
| `'standard'` | Purchased quantity is decremented from `:available` |
| `'displayable_when_out_of_stock'` | Same as `'standard'`, from which it inherits |
| `'allow_backorder'` | Purchased quantity is decremented first from `:available` (until exhausted) and then from `:backordered` |
| `'ignore'` | Nothing is captured |

If a shopper later cancels the order, Workarea must _release_ the inventory, which is the reverse of a capture and relies on the record of the purchase stored in the inventory transaction.


### Inventory Transactions

When an order is placed, the details of the inventory captured are recorded in an _inventory transaction_, a separate document (an `Inventory::Transaction`) which embeds an inventory transaction item for each corresponding order item.
Inventory transactions are used to manage the capturing of inventory and to provide a permanent record of what was captured.
They are also used in the event of a cancellation to free the appropriate amount of inventory.

( Inventory transactions are also covered in [Integrate an Inventory Management System](/articles/integrate-an-inventory-management-system.html). )


### Reports & Insights

Because Workarea is modifying inventory counts, it must provide a means for retailers to stay informed of current inventory levels.
In addition to the inventory SKU administration screens, Workarea provides two reports directly relevant to those responsible for restocking inventory: "Low Inventory" and "Sales by Product".
A retailer can view and export these reports in the Admin.
Insights based on these reports also appear within several Admin dashboards.
Relying on these insights, retailers can effectively manage inventory levels, completing the inventory cycle explained in this document.
