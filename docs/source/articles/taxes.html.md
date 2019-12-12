---
title: Taxes
excerpt: An explanation on the implementation of tax rates and how tax is calculated within Workarea.
created_at: 2019/07/01
---

# Taxes

Workarea provides a mechanism to assign tax codes to both pricing SKUs and shipping services. These tax codes are used to associate administrable tax categories with those prices and shipping services. At a tax category level, rates are defined based on country, region, and/or postal code.

## Configuring tax

Tax configuration begins with creating tax categories. Tax categories enable a business to tax different goods at different rates to accommodate exemptions or product-specific tax rates. A tax category is nothing more than a name and a code. Once created, tax rates can be defined for the category.

![Create a new tax category](/images/new-tax-category.png)



Tax rates can be defined within Workarea one at a time, or a CSV can be imported. Tax rate importing is compatible with files provided by [Avalara](https://www.avalara.com/taxrates/en/download-tax-tables.html) for US tax tables. This makes it easy to pull current tax rates for the US into your application.

![Tax Category Rates](/images/tax-category-rates.png)

Tax rates allow an admin user to define the country, region, and postal code for which the rate will apply. The less specific the rate, the more broadly the rate will apply. However, Workarea will always attempt to find the most specific tax rate for an order first, before using a more generic tax rate (See specificity below for more information).

Tax rates also define the percentage for each country, region, and postal code. This allows for more accurate calculation of tax totals during checkout, but is still combined into a single tax total for each item or shipping service.

The last option on a tax rate is whether that rate should tax shipping. This allows the flexibility to not charge tax on shipping costs for a specific region rather than having specific shipping options for areas that may have different policies on shipping tax.

To use the added tax category for products, the `Pricing::Sku` `tax_code` field should match the code assigned to the tax category.

To use the added tax category for product, the `Shipping::Service` `tax_code` field should match the code assigned to the tax category.

Pricing and shipping services with no tax code, or a tax code that does not match a tax category, will not have tax calculated during checkout.

## Calculating tax

With tax categories set up and tax codes assigned across your catalog, orders can now be taxed. To determine tax, Workarea uses the shipping address of the order during checkout to determine which tax rate within a category to apply. Until a shipping address is known, tax will not be shown for the order.

Tax is calcated individually for each item in the cart and for the shipping method selected by the customer during checkout through the `Workarea::Pricing::Calculators::TaxCalculator`. This calculator determines the amount that is taxable, looks up the best matching tax rate, and calculates the tax amounts. The calculated tax amount is applied through a new `Workarea::PriceAdjustment`. All adjustments for both items and shipping services are added to the `Workarea::Shipping` associated to the order that matches the address used for determining the tax rate. Once calculated, the `Workarea::Pricing::OrderTotals` class adds together all the tax amounts for the order and stores the tax total on the `Workarea::Order`.

### Specificity

Tax rates can have a varying level of specificity. If only country is defined on the rate, then any price or service for an order that has a shipping address within that country is eligible to be taxed with that rate if no other, more specific rate is found. This is also true if only country and region are defined and the shipping address is within that region. Additionally, a rate will not be used to calculate tax for a shipping address that does not match all location-based fields on a tax rate (country, region, and postal code). If, for example, a tax rate defines all 3 fields, but a shipping address only matches country and region, then the tax rate will never be used for that shipping address.

This flexibility can be useful if a larger area is all taxed the same. Instead of having to specify a tax rate for each postal code, a single tax rate could be defined for entire region if there is no variation in the tax percentage for that region.
