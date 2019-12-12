---
title: Define & Configure Inventory Policies
excerpt: Procedures to define additional inventory policies and configure available policies
---

Define & Configure Inventory Policies
======================================================================

Workarea includes multiple inventory policies, which encapsulate the logic for translating the administrable inventory values (e.g. `:available` and `:backordered`) into inventory SKU states (e.g. `#purchasable` and `#displayable`).
( See [Inventory: Inventory Policies & SKU States](/articles/inventory.html#inventory-policies-amp-sku-states) for a full explanation. )
The included policies cover most use cases, but in order to satisfy the business requirements of a retailer, you may need to add one or more additional policies, or you may need to otherwise configure which policies are available (e.g. remove policies or re-order them within the Admin).

To perform these tasks, you need to know how to define and configure inventory policies, which is the subject of this document.
To define your own policy, add a class which implements the inventory policy interface: `#available_to_sell`, `#displayable?`, and `#purchase`.
Then, to make the policy available, or to otherwise affect the available policies, manipulate the configurable inventory policy collection: `Workarea.config.inventory_policies`.


Define New Policies
----------------------------------------------------------------------

To define a new policy, add a class definition at the following path:

`<app or plugin root>/app/models/workarea/inventory/policies/<policy name>.rb`

Within this file, define a class within the module `Workarea::Inventory::Policies` that inherits from `Base` or a policy on which you will base the new policy.

Finally, implement or re-implement any of the following methods that are unique to your policy (if inheriting from `Base`, you'll need to implement all of them):

* `#available_to_sell`
* `#displayable?`
* `#purchase(quantity)`

If you are unfamiliar with any of these methods, see [Inventory: Inventory Policies & SKU States](/articles/inventory.html#inventory-policies-amp-sku-states) and [Inventory: Purchasing, Capturing, and Releasing Inventory](/articles/inventory.html#purchasing-capturing-amp-releasing-inventory), and refer to the implementations of these methods within the existing inventory policies.
The following command will print the pathnames of the inventory policies available to your application:

```bash
find $(pwd) $(bundle show --paths | grep workarea) \
-path '*/app/*/inventory/policies/*.rb' | sort -u
```


### Examples

As an example, the "offline" policy ensures a shopper can view the item on the website but cannot purchase it (which must be done over the phone or by some other means explained on the screen):

```ruby
# <app or plugin root>/app/models/workarea/inventory/policies/offline.rb

module Workarea
  module Inventory
    module Policies
      class Offline < Base
        def displayable?
          true
        end

        def available_to_sell
          0
        end

        def purchase(quantity)
          # noop
        end
      end
    end
  end
end
```

The "in store only" policy relies on other extensions that exist in the application or plugin:

```ruby
# <app or plugin root>/app/models/workarea/inventory/policies/in_store_only.rb

module Workarea
  module Inventory
    module Policies
      class InStoreOnly < Standard
        def available_to_sell
          sku.available_in_store
        end

        def purchase(quantity)
          # noop
        end
      end
    end
  end
end
```


Configure Available Policies
----------------------------------------------------------------------

Add your new policy to the configurable collection of available inventory policies:

```ruby
# <app or plugin root>/config/initializers/inventory_policies.rb

Workarea.config.inventory_policies << 'Workarea::Inventory::Policies::Offline'
```

You can also remove or sort the policies using the methods of [SwappableList](/articles/swappable-list-data-structure.html).
When saving an inventory policy, its policy is validated to ensure it is a member of this collection.
And this is the list of policies that is presented for selection within the inventory SKU administration screens.
The first policy in this collection is the default policy for new inventory SKUs.
