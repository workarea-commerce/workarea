---
title: Analytics Overview
created_at: 2019/03/14
excerpt: The Workarea platform has a built-in framework for allowing analytics plugins to share data, and to facilitate using multiple analytics platforms simultaneously.
---

# Analytics Overview

The Workarea platform has a built-in framework for allowing analytics plugins to share data, and to facilitate using multiple analytics platforms simultaneously.

## Data

The data for analytics is presented in the form of HTML data attributes on various elements throughout the application.

This example shows the analytics data available for a category view event.

http://your-app.com/categories/shirts :

```
<div class='view' data-analytics='{"event":"categoryView","payload":{"name":"Shirts","sort":"top_sellers","page":1,"filters":{"color":["Blue"]}}}'>
  <h1>Shirts</h1>
  <!-- ... -->
</div>
```

This example shows the analytics HTML data for a user's shipping method selection.

http://your-app.com/checkout/shipping :

```
<input type="radio" name="shipping_method_id" id="shipping_method_id_55537ba742656e3004bc0300" value="55537ba742656e3004bc0300" data-analytics='{"event":"checkoutShippingMethodSelected","domEvent":"click","payload":{"id":"55537ba742656e3004bc0300","name":"Ground","price":7.0}}' checked="checked">
```

There are three parts to the analytics HTML data:

| Type | Description |
| --- | --- |
| `event` | Name of the analytics event being published |
| `domEvent` | Name of the DOM event which will trigger the analytics event (if this is not present, the event fires on page load) |
| `payload` | Data that will be made available to analytics adapters |

This data is assembled by a view helper: `Workarea::Storefront::AnalyticsHelper`. Customize this helper to extend data points.

## Events

The analytics framework reads this data, does some processing on certain events, and calls the appropriate callbacks in the analytics adapter, passing in the payload along with any additionally acquired data. The events which include more data than the payload include `productList`, `productClick`, and `updateCartItem`.

| Type | Description |
| --- | --- |
| `productList` | The framework gathers all product impressions in the list, and includes them in the data it sends to adapter callbacks in the `impressions` value. |
| `productClick` | The framework finds the product list, and includes the `list` which is the product list name and `position` which is the product's position in that list. |
| `updateCartItem` | The framework adds `from` and `to` values to indicate how the quantity is changing. |
