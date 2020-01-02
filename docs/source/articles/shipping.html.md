---
title: Shipping
created_at: 2018/07/31
excerpt: A shipping (Workarea::Shipping) is an application document that represents shipping and pricing information for an order or a subset of an order.
---

# Shipping

## Shipping

A <dfn>shipping</dfn> (`Workarea::Shipping`) is an [application document](/articles/application-document.html) that represents shipping and pricing information for an order or a subset of an order.

### Order

A shipping is associated with an order. An order may be associated with many shippings, but without customization, the Workarea checkout models and UI assume one shipping per order. The `order_id` field on a shipping identifies its associated order.

```
# returns the first shipping for the given order id
Workarea::Shipping.find_by_order(order_id)

# returns all shippings with the given order id
Workarea::Shipping.where(order_id: order_id).to_a
```

### Address

A shipping embeds one shipping address. `Shipping#set_address` builds and saves the embedded address from the given attributes.

```
shipping.set_address(
  first_name: 'Bob',
  last_name: 'Clams',
  street: '22 S 3rd St',
  city: 'Philadelphia',
  region: 'PA',
  postal_code: '19106',
  country: 'US'
)
# => true

shipping.address.class
# => Workarea::Shipping::Address

shipping.address.first_name
# => "Bob"
```

### Service Selection

A shipping embeds one service selection. `Shipping#apply_shipping_service` builds the embedded service selection without persisting it. `Shipping#set_shipping_service` builds and saves the embedded service selection, using `apply_shipping_service` within its implementation.

`Shipping#apply_shipping_service` resets the price adjustments and shipping total on the shipping and then sets a _shipping_ price adjustment on the shipping. This price adjustment represents the base price of the service selection. See pricing example, below.

### Pricing

A shipping embeds many price adjustments. While order items embed all _item_ and _order_ price adjustments, shippings embed all _shipping_ and _tax_ price adjustments. The price adjustments on a shipping may represent the following:

- The base price of the service selection embedded within the shipping
- Each discount on the service selection embedded within the shipping
- The tax price of the service selection embedded within the shipping
- The tax price of each order item associated with the shipping

`Shipping#base_price` returns the `amount` of the _shipping_ price adjustment on the shipping, if any. `Shipping#shipping_total` and `Shipping#tax_total` are `Money` values that default to zero when a shipping is initialized and are updated when the shipping is priced by the Workarea pricing model. See pricing example, below.

### Pricing Example

```
# create tax category
Workarea::Tax::Category.destroy_all
sales_tax_category = Workarea::Tax::Category.create!(
  name: 'Sales Tax',
  code: '001'
)

# create tax rate
sales_tax_category.rates.create!(
  country: 'US',
  region: 'PA',
  percentage: 0.05
)

# create pricing sku
Workarea::Pricing::Sku.destroy_all
Workarea::Pricing::Sku.create!(
  _id: 'small-shirt',
  prices: [{ regular: 10 }],
  tax_code: '001'
)

# create shipping service
Workarea::Shipping::Service.destroy_all
shipping_service = Workarea::Shipping::Service.create!(
  name: 'Standard', rates: [{ price: 6 }], tax_code: '001'
)

# create shipping discount
Workarea::Pricing::Discount::Shipping.destroy_all
Workarea::Pricing::Discount::Shipping.create!(
  name: "$5 #{shipping_service.name} Shipping",
  shipping_service: shipping_service.name,
  amount: 5
)

# create order with item
Workarea::Order.destroy_all
order = Workarea::Order.create!(
  items: [{ product_id: 'shirt', sku: 'small-shirt', quantity: '1' }]
)

# create shipping
Workarea::Shipping.destroy_all
shipping = Workarea::Shipping.create!(order_id: order.id)

# set shipping address
shipping.set_address(
  first_name: 'Bob',
  last_name: 'Clams',
  street: '22 S 3rd St',
  city: 'Philadelphia',
  region: 'PA',
  postal_code: '19106',
  country: 'US'
)

# set shipping service selection
Workarea::Pricing.perform(order)
shipping_option = shipping_service.to_option(order.subtotal_price)
shipping.set_shipping_service(shipping_option.to_h)

# price the order and shipping
Workarea::Pricing.perform(order, shipping)

shipping.price_adjustments.map(&:price)
# => ["shipping", "shipping", "tax", "tax"]

shipping.price_adjustments.map(&:description)
# => ["Standard", "$5 Standard Shipping", "Tax", "Tax"]

shipping.price_adjustments.map(&:calculator)
# => ["Workarea::Shipping", "Workarea::Pricing::Discount::Shipping", "Workarea::Pricing::TaxApplier", "Workarea::Pricing::TaxApplier"]

shipping.price_adjustments.map { |a| a.amount.to_s }
# => ["6.00", "-1.00", "0.50", "0.25"]

shipping.base_price.to_s
# => "6.00"

shipping.shipping_total.to_s
# => "5.00"

shipping.tax_total.to_s
# => "0.75"
```

### Options

`Shipping#find_method_options` returns shipping options that qualify for the shipping and the given packages. Each shipping option is created from a rate estimate provided by the configured carrier. Price adjustments are not set on these options, so the price of each reflects the base price only.

```
# clear all shipping services
Workarea::Shipping::Service.destroy_all

# create 2 location agnostic shipping services
Workarea::Shipping::Service.create!(
  name: 'Standard',
  rates: [{ price: 5 }]
)
Workarea::Shipping::Service.create!(
  name: 'Priority',
  rates: [{ price: 10 }]
)

# create 2 location specific shipping services
Workarea::Shipping::Service.create!(
  name: 'PA Standard',
  rates: [{ price: 5 }],
  country: 'US',
  regions: ['PA']
)
Workarea::Shipping::Service.create!(
  name: 'PA Priority',
  rates: [{ price: 10 }],
  country: 'US',
  regions: ['PA']
)

# create order and shipping
order = Workarea::Order.create!
shipping = Workarea::Shipping.create!(
  order_id: order.id,
  address: {
    first_name: 'Bob',
    last_name: 'Clams',
    street: '22 S 3rd St',
    city: 'Philadelphia',
    region: 'PA',
    postal_code: '19106',
    country: 'US'
  }
)

# init packages
packages = Workarea::Packaging.new(order, shipping).packages

# list names of ALL shipping services
Workarea::Shipping::Service.all.to_a.map(&:name)
# => ["Standard", "Priority", "PA Standard", "PA Priority"]

# list names of QUALIFYING shipping options (each corresponding to a service)
shipping.find_method_options(packages).map(&:name)
# => ["PA Standard", "PA Priority"]
```

## Address

A <dfn>shipping address</dfn> (`Workarea::Shipping::Address`) is an embedded [application document](/articles/application-document.html) that represents the address to which its parent shipping is to be shipped.

### Fields

A shipping address has the following fields (required fields indicated).

- `first_name` (required)
- `last_name` (required)
- `company`
- `street` (required)
- `street_2`
- `city` (required)
- `region` (required if country has regions)
- `postal_code` (required if country has postal codes)
- `country` (required)
- `phone_number`
- `phone_extension`

A shipping address also applies the following validations and transformations.

- All fields have a max length of 500 characters
- `street` and `street_2` cannot be a PO Box, as defined by the pattern in `Workarea.config.po_box_regex`
- The `phone_number` setter strips non-digits

### ActiveShipping

`Shipping::Address#to_active_shipping` initializes and returns an ActiveShipping location representing the address.

```
shipping = Workarea::Shipping.create!(
  address: {
    first_name: 'Bob',
    last_name: 'Clams',
    street: '22 S 3rd St',
    city: 'Philadelphia',
    region: 'PA',
    postal_code: '19106',
    country: 'US'
  }
)

# address attributes
shipping.address.as_document
# => {
# "_id" => BSON::ObjectId('58d42851eefbfefd52cc4b6b'),
# "_type" => "Workarea::Shipping::Address",
# "first_name" => "Bob",
# "last_name" => "Clams",
# "street" => "22 S 3rd St",
# "city" => "Philadelphia",
# "region" => "PA",
# "postal_code" => "19106",
# "country" => "US"
# }

# location attributes
shipping.address.to_active_shipping.to_hash
# => {
# :country => "US",
# :postal_code => "19106",
# :province => "PA",
# :city => "Philadelphia",
# :name => nil,
# :address1 => nil,
# :address2 => nil,
# :address3 => nil,
# :phone => nil,
# :fax => nil,
# :address_type => nil,
# :company_name => nil
# }
```

## Service Selection

A <dfn>shipping service selection</dfn> (`Workarea::Shipping::ServiceSelection`) is an embedded [application document](/articles/application-document.html) that represents the shipping service for its parent shipping.

A service selection's `name`, `carrier`, and `service_code` should identify a shipping service within the retailer's fulfillment system. The `tax_code` field identifies the applicable tax category within the Workarea system.

## Shipping Option

A <dfn>shipping option</dfn> (`Workarea::ShippingOption`) is an object representing a _qualifying_ shipping service for an order or shipping (if multiple shippings). While a rate estimate represents a shipping service from the carrier's perspective, a shipping option represents a shipping service from the perspective of the Workarea system, including `tax_code` and `price_adjustments`.

```
shipping_option.name
# => "Media Mail"

shipping_option.carrier
# => "USPS"

shipping_option.service_code
# => "Media Mail Parcel"

shipping_option.tax_code
# => "001"
```

### Pricing

Within checkout, shipping options are presented with an adjusted price (the absolute sum of all _shipping_ price adjustments). After a customer selects a shipping option, the selected shipping option is used to persist a service selection on the shipping. The service selection includes the `tax_code`, which is used to calculate a `tax` price adjustment on the shipping.

A shipping option may be initialized with a price (stored in `@price`) and may have price adjustments (stored in `@price_adjustments`). The methods `price` and `base_price` return the adjusted and non-adjusted price, respectively. When `@price_adjustments` is empty, both methods return the same value.

```
shipping_option.price_adjustments.map{ |a| a.amount.to_s }
# => ["-1.00"]

shipping_option.base_price.to_s
# => "6.00"

shipping_option.price.to_s
# => "5.00"
```

### Initializing

A shipping option can be initialized from an rate estimate or a shipping service. Additionally, `Shipping#find_method_options` and `Checkout::ShippingOptions#available` return collections of shipping options.

#### From Rate Estimate

When initializing from a rate estimate, `price` is typecast to `Money`. Additionally, `Shipping::Service.find_tax_code` finds the value for `tax_code` using the `carrier` and `service_name`. When an application is configured to use a shipping carrier other than `ActiveShipping::Workarea`, shipping service models are likely not used for rate estimates. However, they will still be used to look up tax codes. Any application concerned with shipping service tax codes must therefore persist shipping services.

```
# rate estimate attributes
JSON.parse(rate_estimate.to_json)
=> {
# "origin" => {} # truncated
# "destination" => {} # truncated
# "carrier" => "USPS",
# "service_name" => "Media Mail",
# "service_code" => "Media Mail Parcel",
# "description" => nil,
# "estimate_reference" => nil,
# "pickup_time" => nil,
# "expires_at" => nil,
# "package_rates" => [],
# "total_price" => 600,
# "negotiated_rate" => nil,
# "compare_price" => nil,
# "phone_required" => false,
# "currency" => "USD",
# "delivery_range" => [],
# "shipping_date" => nil,
# "delivery_date" => nil,
# "insurance_price" => nil,
# "delivery_category" => nil,
# "shipment_options" => [],
# "charge_items" => []
# }

# shipping option attributes
Workarea::ShippingOption.from_rate_estimate(rate_estimate).to_h
# => {
# :carrier => "USPS",
# :name => "Media Mail",
# :service_code => "Media Mail Parcel",
# :price => #<Money fractional:600 currency:USD>,
# :base_price => #<Money fractional:600 currency:USD>,
# :tax_code => "001"
# }
```

#### From Shipping Service

`ShippingService#to_option(subtotal)` initializes a shipping option from a shipping service, using the provided subtotal to look up the qualifying rate. The shipping service `name` is flattened to a string (from localization hash) and `price` is added.

```
# shipping service attributes
JSON.parse(shipping_service.to_json)
# => {
# "_id" => "58d43b5aeefbfefd52cc4bc0",
# "carrier" => "USPS",
# "country" => nil,
# "created_at" => "2017-03-23T21:17:14.731Z",
# "name" => "Media Mail",
# "rates" => [{
# "_id" => "58d43b5aeefbfefd52cc4bc1",
# "created_at" => nil,
# "price" => {"cents" => 500.0, "currency_iso" => "USD"},
# "tier_max" => nil,
# "tier_min" => nil,
# "updated_at" => nil
# }],
# "regions" => nil,
# "service_code" => "Media Mail Parcel",
# "subtotal_max" => nil,
# "subtotal_min" => nil,
# "tax_code" => "001",
# "updated_at" => "2017-03-23T21:17:14.731Z"
# }

# shipping option attributes
shipping_service.to_option(25).to_h
# => {
# :carrier => "USPS",
# :name => "Media Mail",
# :service_code => "Media Mail Parcel",
# :price => #<Money fractional:500 currency:USD>,
# :base_price => #<Money fractional:500 currency:USD>,
# :tax_code => "001"
# }
```

#### From Shipping & Packages

`Shipping#find_method_options` requests rate estimates from the configured shipping carrier and maps each to a shipping option, returning a collection of shipping options (see options, above). This method uses `ShippingOption.from_rate_estimate` within its implementation (see from rate estimate, above).

#### From Order & Shipping

The Workarea checkout service uses `Workarea::Checkout::ShippingOptions#available` to return the collection of shipping options that qualify for the checkout, using information from the checkout's order and shipping. Since this API has access to an order and a shipping, the shipping options it returns have price adjustments representing any discounts on the shipping service selection. **This is the only API that returns shipping options with price adjustments.**

```
# create 2 shipping services
Workarea::Shipping::Service.destroy_all
standard_shipping_service = Workarea::Shipping::Service.create!(
  name: 'Standard',
  rates: [{ price: 6 }]
)
free_shipping_service = Workarea::Shipping::Service.create!(
  name: 'FREE',
  rates: [{ price: 0 }],
  subtotal_min: 50
)

# create shipping discount
Workarea::Pricing::Discount::Shipping.destroy_all
Workarea::Pricing::Discount::Shipping.create!(
  name: "$5 #{shipping_service.name} Shipping",
  shipping_service: shipping_service.name,
  amount: 5
)

# create pricing sku
Workarea::Pricing::Sku.destroy_all
Workarea::Pricing::Sku.create!(
  _id: 'small-shirt',
  prices: [{ regular: 10 }]
)

# create order with item
Workarea::Order.destroy_all
order = Workarea::Order.create!(
  items: [{ product_id: 'shirt', sku: 'small-shirt', quantity: '1' }]
)

# create shipping with address
Workarea::Shipping.destroy_all
shipping = Workarea::Shipping.create!(
  order_id: order.id,
  address: {
    first_name: 'Bob',
    last_name: 'Clams',
    street: '22 S 3rd St',
    city: 'Philadelphia',
    region: 'PA',
    postal_code: '19106',
    country: 'US'
  }
)

# price the order and shipping
Workarea::Pricing.perform(order, shipping)

shipping_options = Workarea::Checkout::ShippingOptions.new(order, shipping).available

# ALL shipping services
Workarea::Shipping::Service.count
# => 2

# QUALIFYING shipping options
shipping_options.count
# => 1

shipping_option = shipping_options.first

shipping_option.name
# => "Standard"

# price, including discount(s)
shipping_option.price.to_s
# => "5.00"

# find corresponding shipping service
shipping_service = Workarea::Shipping::Service.find_by(name: shipping_option.name)

# base price of shipping service (excludes discounts)
shipping_service.find_rate(order.subtotal_price).price.to_s
# => "6.00"
```

### Serializing

`ShippingOption#to_h` serializes a shipping option into attributes appropriate for the initialization of a shipping service selection. This method is used to persist a shipping option as a shipping service selection via `Shipping#apply_shipping_service`.

```
shipping_option.to_h
# => {
# :carrier => "USPS",
# :name => "Media Mail",
# :service_code => "Media Mail Parcel",
# :price => #<Money fractional:600 currency:USD>,
# :base_price => #<Money fractional:600 currency:USD>,
# :tax_code => "001"
# }
```

## ActiveShipping

Workarea uses [ActiveShipping (v1.8)](http://www.rubydoc.info/gems/active_shipping/1.8.6), a Ruby API that abstracts the web services of various shipping carriers.

### Carrier

A Workarea application is configured with an ActiveShipping carrier (`ActiveShipping::Carrier`, [docs](http://www.rubydoc.info/gems/active_shipping/1.8.6/ActiveShipping/Carrier)) from which it will request shipping rates using `ActiveShipping::Carrier#find_rates` ([docs](http://www.rubydoc.info/gems/active_shipping/1.8.6/ActiveShipping/Carrier#find_rates-instance_method)). `find_rates` has the following signature.

```
ActiveShipping::Carrier#find_rates(origin, destination, packages, options = {}) â ActiveShipping::RateResponse
```

A rate request therefore requires `origin` and `destination`, which are locations, and a collection of packages. For most carriers, the rate request happens over HTTP. The request returns a response, which, if successful, includes a collection of rate estimates.

### Workarea Shipping Carrier

`Workarea.config.gateways.shipping` holds an instance of the currently configured carrier. The default shipping carrier is `ActiveShipping::Workarea`, which implements `find_rates` as follows.

```
Workarea::Shipping::RateLookup.new(origin, destination, packages, options).response
```

This implementation does not require an HTTP request, and the response from `Shipping::RateLookup#response` is always successful. The returned collection of rate estimates is initialized from the set of qualifying shipping services persisted in MongoDB. To determine qualifying shipping services, services are queried by country and region (using the address on the shipping) and by price (using the order subtotal). The services within the intersection of these queries are used to initialize the collection of rate estimates for the response.

### Location

An ActiveShipping location (`ActiveShipping::Location`, [docs](http://www.rubydoc.info/gems/active_shipping/1.8.6/ActiveShipping/Location)) represents either the origin or destination location to use during fulfillment of an order.

The destination location is created from the shipping address, while the origin is created from the attributes held in `Workarea.config.shipping_origin`.

```
Workarea.config.shipping_origin
# => {:country=>"US", :state=>"PA", :city=>"Philadelphia", :zip=>"19106"}
```

### Package

An ActiveShipping package (`ActiveShipping::Package`, [docs](http://www.rubydoc.info/gems/active_shipping/1.8.6/ActiveShipping/Package)) represents a physical package to be delivered as part of order fulfillment. See packaging, below.

### Response

An ActiveShipping response (`ActiveShipping::Response`, [docs](http://www.rubydoc.info/gems/active_shipping/1.8.6/ActiveShipping/Response)) represents the response from a carrier for rate estimates. With the exception of the Workarea shipping carrier, the request and response typically occurs over HTTP. The response will indicate success or failure and provide rate estimates.

### Rate Estimate

An ActiveShipping rate estimate (`ActiveShipping::RateEstimate`, [docs](http://www.rubydoc.info/gems/active_shipping/1.8.6/ActiveShipping/RateEstimate)) represents a qualified shipping service for the customer to select. During checkout, rate estimates are used to initialize shipping options, which unlike rate estimates, can present adjusted pricing.

## Sku

A <dfn>shipping sku</dfn> (`Workarea::Shipping::Sku`) is an [application document](/articles/application-document.html) that represents the shipping attributes for a catalog variant (`Workarea::Catalog::Variant`). The `_id` of a shipping sku matches the `sku` of the variant with which it is associated.

```
variant.sku == shipping_sku.id.to_s
# => true
```

Without customization, a shipping sku has `weight` and `dimensions` fields. By default, weight is measured in ounces and dimensions are measured in inches. An application can use metric units by changing the ActiveShipping options held in `Workarea.config.shipping_options`.

```
Workarea.config.shipping_options
# => { :units => :imperial }
```

The Workarea packaging service finds the shipping sku for each order item within an order to construct one or many packages for the order (or its associated shipping, if multiple shippings).

## Packaging

The Workarea <dfn>packaging service</dfn> (Workarea::Packaging) initializes a collection of packages for a given order and shipping. Packages are needed to request rate estimates from an ActiveShipping carrier.

### Default Implementation

Without customization, the Workarea checkout service assumes one shipping per order. By default, the packaging service therefore ignores the provided shipping and always returns a collection with a single package representing the entire order.

The weight and dimensions of the package are derived from the combined weight and dimensions of all items to be included in the package, as stored on the shipping sku that corresponds to each order item. If a shipping sku is not persisted for an item in the order, a new shipping sku (with default values) is used to represent that item in the package.

If the dimensions of any item in the package are unknown, the value held in `Workarea.config.shipping_dimensions` is used as the dimensions of the package. For this reason, this value should represent the average or standard box size used to fulfill orders.

```
Workarea.config.shipping_dimensions
# => [1, 1, 1]
```

The following example demonstrates the process of initializing packages from an order and shipping.

```
Workarea::Catalog::Product.destroy_all
product = Workarea::Catalog::Product.create!(
  name: 'shirt',
  variants: [{ sku: 'large-shirt' }]
)
sku = product.variants.first.sku
Workarea::Shipping::Sku.destroy_all
Workarea::Shipping::Sku.create!(
  _id: sku,
  weight: 5.0,
  dimensions: [11, 9, 2]
)
Workarea::Order.destroy_all
order = Workarea::Order.create!(
  items: [{
    product_id: product.id,
    sku: sku,
    quantity: '1'
  }]
)
Workarea::Shipping.destroy_all
shipping = Workarea::Shipping.create!(order_id: order.id)
package = Workarea::Packaging.new(order, shipping).packages.first

package.ounces
# => 5.0

package.inches
# => [2, 9, 11]
```

### Extension

Although it receives a collection of packages, the default shipping carrier ignores them when constructing its list of qualifying rate estimates. However, this is unlikely to be true for other carriers.

The default packaging logic may be too naive for some applications, but the complexities required to handle all possibilities is beyond the scope of the Workarea platform. Applications using a shipping carrier that relies on packaging may need to decorate the packaging service to implement the logic preferred by the retailer.

## Service

A <dfn>shipping service</dfn> (`Workarea::Shipping::Service`) is an [application document](/articles/application-document.html) that represents a shipping service by which an order can be fulfilled. A shipping service may represent a specific shipping product, such as _FedEx Ground_, or may represent a more abstract shipping service, such as _Standard Shipping_ or _Free Shipping_.

The Workarea shipping carrier uses the persisted shipping services to construct a collection of rate estimates, which are then used to initialize shipping options to present to the customer during checkout.

### Fields

A shipping service must have a `name`, and may also have values for `carrier`, `service_code`, and `tax_code`.

```
shipping_service.name
# => "Media Mail"

shipping_service.carrier
# => "USPS"

shipping_service.service_code
# => "Media Mail Parcel"

shipping_service.tax_code
# => "001"
```

### Rates

A service embeds many rates representing the base prices of the service. `Shipping::Service#find_rate` finds the lowest qualifying rate for the given amount (typically the order subtotal).

```
standard_shipping_service = Workarea::Shipping::Service.create!(
  name: 'Standard',
  rates: [
    { price: 5, tier_max: 49.99 },
    { price: 10, tier_max: 99.99 },
    { price: 15, tier_min: 100 }
  ]
)

standard_shipping_service.find_rate((49.99).to_m).price.to_s
# => "5.00"

standard_shipping_service.find_rate((50.00).to_m).price.to_s
# => "10.00"

standard_shipping_service.find_rate((99.99).to_m).price.to_s
# => "10.00"

standard_shipping_service.find_rate((100.00).to_m).price.to_s
# => "15.00"

standard_shipping_service.find_rate((500.00).to_m).price.to_s
# => "15.00"
```

### Querying

`Shipping::Service.for_location` queries services by country and region, while `Shipping::Service.by_price` queries services by price.

### By Country & Region

```
Workarea::Shipping::Service.destroy_all
Workarea::Shipping::Service.create!(name: 'Standard', rates: [{ price: 5 }])
Workarea::Shipping::Service.create!(name: 'Priority', rates: [{ price: 10 }])
Workarea::Shipping::Service.create!(name: 'Express', rates: [{ price: 20 }])

Workarea::Shipping::Service.for_location('US', 'PA').map(&:name)
# => ["Standard", "Priority", "Express"]

standard_shipping_service = Workarea::Shipping::Service.find_by(name: 'Standard')
standard_shipping_service.update_attributes!(country: 'US', regions: ['PA'])

Workarea::Shipping::Service.for_location('US', 'PA').map(&:name)
# => ["Standard"]
```

### Services by Price

```
Workarea::Shipping::Service.destroy_all
Workarea::Shipping::Service.create!(name: 'Standard', rates: [{ price: 10 }])
Workarea::Shipping::Service.create!(name: 'FREE', rates: [{ price: 0 }], subtotal_min: 50)

Workarea::Shipping::Service.by_price((49.99).to_m).map(&:name)
# => ["Standard"]

Workarea::Shipping::Service.by_price((50.00).to_m).map(&:name)
# => ["Standard", "FREE"]

standard_shipping_service = Workarea::Shipping::Service.find_by(name: 'Standard')
standard_shipping_service.update_attributes!(subtotal_max: 49.99)
Workarea::Shipping::Service.by_price((49.99).to_m).map(&:name)
# => ["Standard"]

Workarea::Shipping::Service.by_price((50.00).to_m).map(&:name)
# => ["FREE"]
```

### Rate

A <dfn>shipping rate</dfn> (Workarea::Shipping::Rate) is an embedded [application document](/articles/application-document.html) that represents a price for its parent shipping service as well as any data that may be used to qualify the rate.

By default, a rate is qualified by comparing its `tier_min` and `tier_max` to a given amount.

A rate has a required `price` field that represents a base price for the parent service.

```
shipping_service.rates.first.price.to_s
# => "5.00"

shipping_service.rates.first.tier_max.to_s
# => "49.99"
```

