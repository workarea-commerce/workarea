---
title: Fulfillment SKUs
created_at: 2019/10/02
excerpt: Define how products in your catalog are fulfilled. Fulfillment SKUs allow the automation of digital and similar items.
---

# Fulfillment SKUs

Workarea v3.5 adds the concept of a Fulfillment SKU -- a model that defines policies for delivering ordered products to customers. This provides a more robust mechanism for the fulfillment of digital items while providing the flexibility to offer customized delivery behaviors at the SKU level.

a `Workarea::Fulfillment::Sku` is comprised of an ID and a policy. The ID corresponds to the SKU of a product variant, and aligns with the IDs of pricing, inventory, and shipping SKUs. The policy defines what is done to fulfill an item after an order has been placed.

```ruby
module Workarea
  class Fulfillment
    module Policies
      class Download
        def process(order_item:, fulfillment: nil)
          # will be called when an SKU with this policy is purchased.
        end
      end
    end
  end
end
```

## Fulfillment Policies

By default, Workarea offers two policies -- `shipping`, and `download`. Picking a policy will do two things: first, it will control the flow of checkout, which will not ask a customer for a shipping address or shipping method when it is not required for the items in their cart. Second, it will allow any automated behavior (such as creating a download token or sending a gift card) when the order is placed.

The `shipping` policy will require shipping info selection during checkout. It does nothing automatically when the order is placed. **This is the default policy used when no policy exists for a SKU.**

The `download` policy will automatically generate a `Fulfillment::Token` for a customer when they purchase a SKU with that policy. This token provides a unique URL to the customer that is specific to their order and account. This will allow them to download the `file` tied to the Fulfillment SKU from the provided link on the order confirmation page, in the confirmation email, and/or in their order history.  

## Fulfillment Tokens

A `Fulfillment::Token` is a document associated to the Fulfillment SKU that stores a secure random string. This association allows a URL with a unique token to be used to provide access to the `file` on the `Fulfillment::SKU` document. Tokens will also be associated to a user and an order if generated as a result of a customer placing an order. Tokens can also be generated via the admin UI.

Tokens do not expire, and the URLs they generate are not restricted to a specific user. However, the number of times a token is downloaded is tracked and displayed within the admin UI. If an admin user notices an unusually high number of downloads for a token, they can disable that token and prevent it from being used for any future downloads.

![Fulfillment Tokens UI](/images/fulfillment-tokens.png)

## Custom Fulfillment Policies

Creating a new fulfillment policy requires two steps -- the creation of the policy class and updating the configuration.

A policy class should inherit from `Workarea::Fulfillment::Policies::Base` and define a `#process` method.

```ruby
module Workarea
  class Fulfillment
    module Policies
      class GenerateTicket < Base
        def process(order_item:, fulfillment: nil)
          # use order_item information to generate ticket
          # update the fulfillment to reflect the generation of the ticket
        end
      end
    end
  end
end
```

Once a new policy class is in place, add it to the swappable list of policies in `Workarea.config.fulfillment_policies`

```ruby
# config/initializers/workarea.rb
Workarea.configure do |config|
  config.fulfillment_policies << 'Workarea::Fulfillment::Policies::GenerateTicket'
end
```
