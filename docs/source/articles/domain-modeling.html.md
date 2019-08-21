---
title: Domain Modeling
created_at: 2018/09/17
excerpt: Here are a few key concepts related to domain modeling and how they are applied within the platform.
---

# Domain Modeling

Here are a few key concepts related to domain modeling and how they are applied within the platform.

**Note:** It's important to keep in mind these are guidelines, and are not followed completely or religiously. Instead, think of them as heuristics when reading the code or extending elements of the platform.

## Bounded Contexts

With large domains (ecommerce is certainly one of these), it becomes difficult to track the intricacies of how models relate to one another. Therefore, Workarea separates these models into different contexts as a way to break down the bigger picture into more manageable pieces. Each context addresses a single problem or set of problems within the larger system. This technique reduces coupling along domain lines and allows functionality to change independently.

To see this in Workarea, look at how the `app/models` directory in Workarea Core is divided. Each subdirectory is a bounded context, such as the following:

- `Catalog`
- `Content`
- `Fulfillment`
- `Inventory`
- `Navigation`
- `Order`
- `Payment`
- `Pricing`
- `Recommendation`
- `Shipping`
- `Tax`
- `User`

### Orders Example

From a customer's perspective, an "order" might contain the following elements:

- Products
- Prices
- Shipping method
- Credit card

By handling these problems separately, the code/modeling/logic for each is much simpler and less coupled. For instance, logic around what shipping methods are available has no coupling to putting together the pricing for the order, even though shipping methods will always have and depend on a price.

However, to present the order to the customer, Workarea pulls:

- Some products from the `Catalog::Product` class
- Pricing for the order items from the `Pricing` engine
- Available shipping methods from the `Shipping::Method` class
- A credit card from the `Payment`

This is the responsibility of the view model layer (and one of the reasons it exists).

### Pricing Example

In another example, pricing from a business user's perspective probably includes several elements:

- SKU price
- Discounts
- Shipping costs
- Taxes

This can get quite complicated, so it is effective to break the problem apart:

- SKU price - stored and calculated in the `Pricing` engine
- Discounts - stored and calculated in the `Pricing` engine
- Shipping costs - stored and calculated by the `Shipping` module and totalled by the `Pricing` engine
- Taxes - rates are stored calculated by the `Tax` module, but applied by the `Pricing` engine

This design makes it much easier to swap out how shipping or taxes are determined. These can be significant problems in their own right, and many implementations use third parties for these purposes.

## Shared Models

There are some things that the contexts share. Changing these classes may/will require cooperation from a potentially broad range of classes, so it's a risky move.

Examples of classes that are shared include:

- `Address` - generically models an address
- `PriceAdjustment` - represents an adjustment to price, used for tracking/calculating prices
- `Region` and `Country` - models countries and subdivisions of countries
- `ShippingOption` - models a shipping method selectable or selected by a user

So `PriceAdjustment` is used by the `Pricing` engine to create the pricing on the `Order`, `Shipping::Shipment`, etc.


