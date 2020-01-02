---
title: Commerce Model
excerpt: The following diagram is a model of commerce from Workarea's perspective.
---

Commerce Model
======================================================================

The following diagram is a model of _commerce_ from Workarea's perspective.
In this model, Workarea receives _catalog data_ as input and returns _order data_ as output.
Activity within Workarea is represented as a cycle of actions, some of which are completed by _administrators_ within the _Admin_; the rest by _shoppers_ within the _Storefront_.

(
Keep in mind this model is an abstraction of the Workarea system.
In practice, catalog and order data are not the only input/output, and actions within the system are non-linear and asynchronous.
)

![Commerce Model](/images/commerce-model.png)


Code Mappings
----------------------------------------------------------------------

Use this illustration of Workarea to improve your mental model of the system.
Keep this representation of Workarea in mind when reading Workarea code and documentation.

To help you in this regard, the following sections map the actions from the diagram to relevant _models_, _view models_, and _services_ within the base Workarea platform.
(These object types are those used to write to and read from the primary data store.)

Each section provides a command which you can run from the root of your application to list the pathnames of the relevant files within your version of Workarea.


### Admins Manage Catalog

```bash
echo "
$(bundle show workarea-core)/app/models/workarea/catalog/product.rb
$(bundle show workarea-core)/app/models/workarea/catalog/variant.rb
$(bundle show workarea-core)/app/models/workarea/catalog/product_image.rb
$(bundle show workarea-core)/app/models/workarea/pricing/sku.rb
$(bundle show workarea-core)/app/models/workarea/pricing/price.rb
$(bundle show workarea-core)/app/models/workarea/inventory/sku.rb
$(bundle show workarea-core)/app/models/workarea/shipping/sku.rb
$(bundle show workarea-core)/app/services/workarea/copy_product.rb
$(bundle show workarea-core)/app/models/workarea/shipping/service.rb
$(bundle show workarea-core)/app/models/workarea/shipping/rate.rb
$(bundle show workarea-core)/app/models/workarea/tax/category.rb
$(bundle show workarea-core)/app/models/workarea/tax/rate.rb
"
```


### Admins Merchandise Store

```bash
echo "
$(bundle show workarea-core)/app/models/workarea/release.rb
$(bundle show workarea-core)/app/models/workarea/release/changeset.rb
$(bundle show workarea-core)/app/models/workarea/catalog/category.rb
$(bundle show workarea-core)/app/models/workarea/product_rule.rb
$(bundle show workarea-core)/app/models/workarea/search/settings.rb
$(bundle show workarea-core)/app/models/workarea/search/customization.rb
$(bundle show workarea-core)/app/models/workarea/content.rb
$(bundle show workarea-core)/app/models/workarea/content/page.rb
$(bundle show workarea-core)/app/models/workarea/content/block.rb
$(bundle show workarea-core)/app/models/workarea/content/asset.rb
$(bundle show workarea-core)/app/models/workarea/navigation/redirect.rb
$(bundle show workarea-core)/app/models/workarea/navigation/taxon.rb
$(bundle show workarea-core)/app/models/workarea/navigation/menu.rb
$(bundle show workarea-core)/app/models/workarea/recommendation/settings.rb
$(bundle show workarea-core)/app/models/workarea/pricing/discount.rb
"
```


### Shoppers Search & Browse Products

```bash
echo "
$(bundle show workarea-storefront)/app/view_models/workarea/storefront/category_view_model.rb
$(bundle show workarea-storefront)/app/view_models/workarea/storefront/search_view_model.rb
$(bundle show workarea-storefront)/app/view_models/workarea/storefront/search_suggestion_view_model.rb
$(bundle show workarea-storefront)/app/view_models/workarea/storefront/page_view_model.rb
$(bundle show workarea-storefront)/app/view_models/workarea/storefront/content_view_model.rb
$(bundle show workarea-storefront)/app/view_models/workarea/storefront/menu_view_model.rb
$(bundle show workarea-storefront)/app/view_models/workarea/storefront/recommendations_view_model.rb
$(bundle show workarea-storefront)/app/view_models/workarea/storefront/product_view_model.rb
"
```

### Shoppers View Products

```bash
echo "
$(bundle show workarea-storefront)/app/view_models/workarea/storefront/product_view_model.rb
"
```


### Shoppers Create & Manage Carts

```bash
echo "
$(bundle show workarea-core)/app/models/workarea/order.rb
$(bundle show workarea-core)/app/models/workarea/order/item.rb
$(bundle show workarea-core)/app/models/workarea/pricing.rb
$(bundle show workarea-core)/app/models/workarea/price_adjustment.rb
$(bundle show workarea-core)/app/models/workarea/pricing/calculator.rb
$(bundle show workarea-storefront)/app/view_models/workarea/storefront/cart_view_model.rb
$(bundle show workarea-storefront)/app/view_models/workarea/storefront/cart_item_view_model.rb
"
```

### Shoppers Place Orders

```bash
echo "
$(bundle show workarea-core)/app/models/workarea/checkout.rb
$(bundle show workarea-core)/app/models/workarea/checkout/steps/base.rb
$(bundle show workarea-core)/app/models/workarea/payment.rb
$(bundle show workarea-core)/app/models/workarea/payment/transaction.rb
$(bundle show workarea-core)/app/models/workarea/inventory.rb
$(bundle show workarea-core)/app/models/workarea/inventory/transaction.rb
$(bundle show workarea-core)/app/models/workarea/inventory/transaction_item.rb
$(bundle show workarea-core)/app/models/workarea/shipping.rb
$(bundle show workarea-core)/app/models/workarea/shipping/service_selection.rb
$(bundle show workarea-storefront)/app/view_models/workarea/storefront/order_view_model.rb
$(bundle show workarea-storefront)/app/view_models/workarea/storefront/order_item_view_model.rb
$(bundle show workarea-core)/app/models/workarea/pricing/discount/redemption.rb
$(bundle show workarea-core)/app/services/workarea/create_fulfillment.rb
"
```


### Admins Manage Orders

```bash
echo "
$(bundle show workarea-core)/app/models/workarea/fulfillment.rb
$(bundle show workarea-core)/app/models/workarea/fulfillment/item.rb
$(bundle show workarea-core)/app/models/workarea/fulfillment/event.rb
$(bundle show workarea-core)/app/models/workarea/fulfillment/package.rb
$(bundle show workarea-core)/app/models/workarea/pricing/override.rb
$(bundle show workarea-core)/app/models/workarea/pricing/request.rb
$(bundle show workarea-core)/app/models/workarea/payment/refund.rb
$(bundle show workarea-core)/app/services/workarea/cancel_order.rb
$(bundle show workarea-core)/app/services/workarea/copy_order.rb
"
```


### Admins View Insights & Reports

```bash
echo "
$(bundle show workarea-core)/app/models/workarea/metrics/by_day.rb
$(bundle show workarea-core)/app/models/workarea/metrics/by_week.rb
$(bundle show workarea-core)/app/models/workarea/insights/base.rb
$(bundle show workarea-admin)/app/view_models/workarea/admin/insight_view_model.rb
$(bundle show workarea-admin)/app/view_models/workarea/admin/reports/insights_view_model.rb
$(bundle show workarea-core)/app/models/workarea/reports/export.rb
$(bundle show workarea-core)/app/services/workarea/export_report.rb
"
```
