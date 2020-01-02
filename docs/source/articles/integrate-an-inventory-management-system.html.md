---
title: Integrate an Inventory Management System
excerpt: Procedures for integrating Workarea with an external inventory system of record
---

Integrate an Inventory Management System
======================================================================

Workarea provides an inventory system that satisfies the needs of many retailers.
However, some retailers prefer to manage their inventory in another system, usually an enterprise resource planner (ERP).

In this case, you will need to integrate Workarea with the external system to keep their inventory data in sync, which is the subject of this document.
To integrate inventory from an ERP, you must routinely update Workarea's inventory SKUs with data from the authoritative inventory system, specifically the fields `:available` and `:backordered`.
Furthermore, you may need to report to the external system any changes that Workarea makes to these fields, which are recorded in inventory transactions.

This document additionally provides general advice for integrating Workarea with another system (of any type).


Update Inventory SKUs within Workarea
----------------------------------------------------------------------

Within Workarea, each item's inventory is represented by an inventory SKU, which is identified by the item's SKU.
( See [Inventory: Inventory SKUs](/articles/inventory.html#inventory-skus). )
Several administrable fields, primarily the integer fields `:available` and `:backordered`, represent the "raw" inventory data tracked by Workarea.
( See [Inventory: Administrable Fields & Policies](/articles/inventory.html#administrable-fields-amp-policies). )

You must design a strategy for keeping these fields in sync with the corresponding data from the external inventory system.
__Maintaining accurate values for these fields is the core of this integration.__
Refer to "General Tips for System Integration" below for further advice on this matter.


Report Workarea's Inventory Transactions
----------------------------------------------------------------------

Workarea also makes its own changes to the inventory SKU values `:available` and `:backordered` when shoppers place and cancel orders.
( See [Inventory: Purchasing, Capturing & Releasing Inventory](/articles/inventory.html#purchasing-capturing-amp-releasing-inventory). )
You therefore may need to report these changes to the system you are integrating.
( This may not be necessary if the external system manages these changes, perhaps during fulfillment rather than at the point of sale. )

Whenever Workarea captures and frees inventory in this manner, it records details of the changes as an `Inventory::Transaction` specific to the order.
Each inventory transaction is related to an order via its `:order_id` field.
Whenever Workarea performs a capture, rollbak, or restock operation on inventory, its affects are recorded on the inventory transaction document, and its `:updated_at` timestamp is refreshed.
Additionally, you can query whether a transaction's inventory has been captured by examining its boolean `:captured` field.

Inventory transactions are indexed by `:updated_at` and `:captured`, facilitating queries for "captured transactions updated after _date_":

```ruby
# find inventory transactions updated after Midnight

Workarea::Inventory::Transaction.where(
  :updated_at.gt => Time.current.beginning_of_day,
  captured: true
)
```

You can use such a query to fetch the transactions that were updated since your last such query, enabling you to prepare ad-hoc reports to send to the partnering system.
Each inventory transaction embeds a collection of `Inventory::TransactionItem` documents, one document per corresponding `Order::Item`.
Each transaction item has the fields `:sku`, `:available`, and `:backordered`, where `:available` and `:backordered` indicate the number of units captured.
You or the ERP can fetch and share this data routinely to keep the external system in sync with Workarea's inventory changes.


General Tips for System Integration
----------------------------------------------------------------------

Until Workarea provides general-purpose documentation for system integration, a brief summary of the process is described here.


### Determine Responsibilities

An integration involves two systems and two teams, so you must determine who is responsible for what.
Work with the partnering team to determine the following:

* Who is pushing or pulling data?
* According to what schedule or in response to what events?
* Who is responsible for transforming the data to/from the opposing data format?
* When updating, are you updating all the records, or only those that have changed since the last update?
* And who is responsible for determining which records have changed since the last update?


### Build the Integration

Next, build the parts of the integration for which you are responsible.
Tools for this within the Workarea system include:

* [Admin API](https://github.com/workarea-commerce/workarea-api/tree/master/admin)
* [Callbacks workers](/articles/workers.html#callbacks-worker)
* [Scheduled workers](/articles/workers.html#sidekiq-cron-job)
* _Data File Scheduling_ (Commerce Cloud plugin)
