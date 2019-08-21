---
title: Workarea 3.3.12
excerpt: Patch release notes for Workarea 3.3.12.
---

# Workarea 3.3.12

Patch release notes for Workarea 3.3.12.

## Downgrade I18n::JS To Prevent Faker Translations From Loading

Downgrade i18n-js to v3.0.10 to prevent issue with loading Faker
translations in the storefront. This was fixed when v3.0.0 was released,
but broke due to a change in the i18n-js private method API.

### Issues

- [ECOMMERCE-6398](https://jira.tools.weblinc.com/browse/ECOMMERCE-6398)

### Pull Requests

- [3627](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3627/overview)

### Commits

- [8ee31f37d28cf108b5d27020e52d0d0df6f88b53](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/8ee31f37d28cf108b5d27020e52d0d0df6f88b53)

## Convert Attribute Case in Customizations Subclasses

Attribute keys passed into a subclass of `Catalog::Customizations` will
typically convert to `snake_case` so they can be read as methods on the
object. This breaks down when `camelCased` attribute names are
encountered because `String#underscore` seems to not handle case changes
in the word, because instead of "foo_bar" from "fooBar", "foobar" is what
the attribute key looks like. Call `#titleize` on the attribute name before
setting it as an instance variable, this will take both spaces and case
changes into account and treat them as separators of the word.

### Issues

- [ECOMMERCE-6401](https://jira.tools.weblinc.com/browse/ECOMMERCE-6401)

### Pull Requests

- [3626](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3626/overview)

### Commits

- [167887d95ee273e5f641fca4a06ca3a135c937f4](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/167887d95ee273e5f641fca4a06ca3a135c937f4)

## Always Select Option With One Selection in Option Set Templates

In the `option_selects` and `option_thumbnails` templates, options with
only one selection available are now selected by default, avoiding an
additional unnecessary click in order to add the product to cart.

### Issues

- [ECOMMERCE-6415](https://jira.tools.weblinc.com/browse/ECOMMERCE-6415)

### Pull Requests

- [3633](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3633/overview)

### Commits

- [b965a09271d01dd755a6c494534c387acc3c45fd](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/b965a09271d01dd755a6c494534c387acc3c45fd)

## Add Weblinc Office and AlertLogic IPs to Rack Attack Safelist

Prevents Weblinc and AlertLogic IPs from being blocked by `Rack::Attack`
from viewing the application. This also includes integration tests for
all `Rack::Attack` safelisting and throttling rules, enabling
implementers to easily test their own custom rules.

### Issues

- [ECOMMERCE-6404](https://jira.tools.weblinc.com/browse/ECOMMERCE-6404)
- [ECOMMERCE-6378](https://jira.tools.weblinc.com/browse/ECOMMERCE-6378)

### Pull Requests

- [3635](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3635/overview)
- [3614](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3614/overview)

### Commits

- [2516b2ed6ace354a2c010db39a8d877cc8595663](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/2516b2ed6ace354a2c010db39a8d877cc8595663)
- [32259c7db00b82337a3779bc080360430f92cd73](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/32259c7db00b82337a3779bc080360430f92cd73)

## Retain Row Type in Imports/Exports

Workarea previously locked the model class that one updated within an
import or export to the corresponding index from which the user came in
the admin (e.g., for products, the "Import" button will import
`Workarea::Catalog::Product` models and its embedded data). This caused
an issue with models that use "STI" and inherit from others, because the
data file engine couldn't tell the difference between a brand-new
`Pricing::Discount` and a brand-new `Pricing::Discount::FreeGift`, for example.
The `_type` column provided within the CSV/JSON exports will now be used to
instantiate the model so a single discounts data file can contain information
for every type of discount that Workarea supports.

### Issues

- [ECOMMERCE-6399](https://jira.tools.weblinc.com/browse/ECOMMERCE-6399)

### Pull Requests

- [3621](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3621/overview)

### Commits

- [38e659028c1f3b75c1df224b07f06939422eb3eb](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/38e659028c1f3b75c1df224b07f06939422eb3eb)

## Populate Product Attributes In `create_placed_order` Factory

In the real world, a product has its attributes copied into `Order::Item#product_attributes`
before the order is placed. In testing, however, this does not occur,
instead the `product_attributes` hash is empty. Workarea now ensures that the
`#create_placed_order` factory method assigns `product.as_document` as these
attributes in the same way as is done in the application, by utilizing the
`Workarea::OrderItemDetails` service object.

### Issues

- [ECOMMERCE-5869](https://jira.tools.weblinc.com/browse/ECOMMERCE-5869)

### Pull Requests

- [3623](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3623/overview)

### Commits

- [376b1d497056ce94129c787303721308a7c13cd2](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/376b1d497056ce94129c787303721308a7c13cd2)

