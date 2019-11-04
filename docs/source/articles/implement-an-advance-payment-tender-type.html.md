---
title: Implement an Advance Payment Tender Type
excerpt: TODO
created_at: 2019/11/05
---

Implement an Advance Payment Tender Type
======================================================================

TODO: document introduction


Gateways
----------------------------------------------------------------------

TODO: section


Operation Implementations
----------------------------------------------------------------------

TODO: section introduction

_Explain_ operation implementations in the [Payment Tender Types](/articles/payment-tender-types.html) explain doc.


### Authorize

TODO: section introduction


#### Boilerplate

Start with the following boilerplate and customize it as necessary.
Refer to the inline annotations for guidance.

```ruby
# your_engine/app/models/workarea/payment/authorize/your_tender_type.rb [1][2]
module Workarea
  class Payment
    module Authorize
      class YourTenderType #[2]
        include OperationImplementation #[3]
        include YourTenderTypeOperation #[4]

        def complete! #[5]
          gateway_response = #[6]
            handle_gateway_errors do #[7]
              gateway.authorize( #[8]
                transaction.amount.cents, #[9]
                tender.foo,
                tender.bar
              )
            end

          transaction.response = #[10]
            ActiveMerchant::Billing::Response.new( #[11]
              gateway_response.success?, #[12]
              gateway_response.message
            )
        end

        def cancel! #[13]
          return unless transaction.success? #[14]

          gateway_response = #[15]
            handle_gateway_errors do #[7]
              gateway.void( #[16]
                transaction.response.authorization #[17]
              )
            end

          transaction.cancellation = #[18]
            ActiveMerchant::Billing::Response.new( #[11]
              gateway_cancellation.success?, #[12]
              gateway_cancellation.message
            )
        end
      end
    end
  end
end
```

__[1]__
Replace `your_engine` with the pathname for the root of your application or plugin, e.g. `~/workarea-reward-points`.

__[2]__
Replace `your_tender_type` and `YourTenderType` with the name of your tender type, e.g. `reward_points` and `RewardPoints`.

__[3]__
You must include this module to have access to `transaction`, `tender`, and `options`.
See [Payment Tender Types](/articles/payment-tender-types.html).

__[4]__
Replace `YourTenderTypeOperation` with the name of the module you created for your gateway, e.g. `RewardPointsOperation`.
See section [Gateways](#gateways_1).

__[5]__
You must implement `complete!` to fulfill the operation implementation contract.
See [Payment Tender Types](/articles/payment-tender-types.html).

__[6]__
Ultimately, you must assign `transaction.response` to fulfill the operation implementation contract.
See __[10]__.
That value is derived from a response from the gateway, so store the gateway's response for later use.
This example assumes the gateway's response is not already an `ActiveMerchant::Billing::Response`, see __[11]__.

__[7]__
You should handle gateway exceptions.
You should have implemented `handle_gateway_errors` for your gateway.
See section [Gateways](#gateways_1).

__[8]__
Use the appropriate API call for your gateway, which is represented by `gateway` (see section [Gateways](#gateways_1)).
The correct API call is often `authorize`, but refer to your gateway's documentation.

__[9]__
Pass the proper arguments for the gateway API call.
The first argument is typically the amount in cents.
To construct this data, you have access to `transaction`, `tender`, and `options`.
See [Payment Tender Types](/articles/payment-tender-types.html).

__[10]__
You must assign `transaction.response` to fulfill the operation implementation contract.
See [Payment Tender Types](/articles/payment-tender-types.html).

__[11]__
The value assigned must be an object of type [`ActiveMerchant::Billing::Response`](https://www.rubydoc.info/gems/activemerchant/1.100.0/ActiveMerchant/Billing/Response).
The provided boilerplate assumes your gateway does not return this type and therefore constructs an instance manually.
However, if your gateway does return this type, you can assign it directly to `transaction.response`, skipping the need to store the gateway response temporarily in `gateway_response`, see __[6]__.

Boilerplate for that scenario:

```ruby
transaction.response =
  handle_gateway_errors do
    gateway.authorize(
      transaction.amount.cents,
      tender.foo,
      tender.bar
    )
  end
```

__[12]__
Construct the arguments for the Active Merchant response from the original gateway response.
The interface of `gateway_response` will vary by gateway.

__[13]__
You must implement `cancel!` to fulfill the operation implementation contract.
See [Payment Tender Types](/articles/payment-tender-types.html).

__[14]__
You must return early if the transaction wasn't successful to fulfill the operation implementation contract.
See [Payment Tender Types](/articles/payment-tender-types.html).

__[15]__
Ultimately, you must assign `transaction.cancellation` to fulfill the operation implementation contract.
See __[18]__.
That value is derived from a response from the gateway, so store the gateway's response for later use.
This example assumes the gateway's response is not already an `ActiveMerchant::Billing::Response`, see __[11]__.

__[16]__
Use the appropriate API call for your gateway, which is represented by `gateway` (see section [Gateways](#gateways_1)).
The correct API call is often `void`, `cancel`, or `refund`, but refer to your gateway's documentation.

__[17]__
Pass the proper arguments for the gateway API call.
The first argument is typically a reference to the original authorization, such as `transaction.response.authorization` or `transaction.response.params['transaction_id']`.
To construct this data, you have access to `transaction`, `tender`, `options`, and `address`.
See [Payment Tender Types](/articles/payment-tender-types.html).

__[18]__
You must assign `transaction.cancellation` to fulfill the operation implementation contract.
See [Payment Tender Types](/articles/payment-tender-types.html).


#### Example

Here is a concrete example of an authorize operation implementation used in production.

TODO: Replace with released code to ensure the GitHub link is stable.

[`Payment::Authorize::GiftCard` from Workarea Gift Cards master branch](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/models/workarea/payment/authorize/gift_card.rb):

```ruby
module Workarea
  class Payment
    module Authorize
      class GiftCard
        include OperationImplementation
        include GiftCardOperation

        def complete!
          response = gateway.authorize(transaction.amount.cents, tender)

          transaction.response = ActiveMerchant::Billing::Response.new(
            response.success?,
            response.message
          )
        end

        def cancel!
          return unless transaction.success?

          response = gateway.cancel(transaction.amount.cents, tender)

          transaction.cancellation = ActiveMerchant::Billing::Response.new(
            response.success?,
            response.message
          )
        end
      end
    end
  end
end
```

### Purchase

TODO: section introduction


#### Boilerplate

Start with the following boilerplate and customize it as necessary.
Refer to the inline annotations for guidance.

```ruby
# your_engine/app/models/workarea/payment/purchase/your_tender_type.rb [1][2]
module Workarea
  class Payment
    module Purchase
      class YourTenderType #[2]
        include OperationImplementation #[3]
        include YourTenderTypeOperation #[4]

        def complete! #[5]
          gateway_response = #[6]
            handle_gateway_errors do #[7]
              gateway.purchase( #[19]
                transaction.amount.cents, #[9]
                tender.foo,
                tender.bar
              )
            end

          transaction.response = #[10]
            ActiveMerchant::Billing::Response.new( #[11]
              gateway_response.success?, #[12]
              gateway_response.message
            )
        end

        def cancel! #[13]
          return unless transaction.success? #[14]

          gateway_response = #[15]
            handle_gateway_errors do #[7]
              gateway.void( #[16]
                transaction.response.authorization #[17]
              )
            end

          transaction.cancellation = #[18]
            ActiveMerchant::Billing::Response.new( #[11]
              gateway_cancellation.success?, #[12]
              gateway_cancellation.message
            )
        end
      end
    end
  end
end
```

__[19]__
Use the appropriate API call for your gateway, which is represented by `gateway` (see section [Gateways](#gateways_1)).
The correct API call is often `purchase`, but refer to your gateway's documentation.


#### Example

Here is a concrete example of a purchase operation implementation used in production.

TODO: Replace with released code to ensure the GitHub link is stable.

[`Payment::Purchase::GiftCard` from Workarea Gift Cards master branch](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/models/workarea/payment/purchase/gift_card.rb):

```ruby
module Workarea
  class Payment
    module Purchase
      class GiftCard
        include OperationImplementation
        include GiftCardOperation

        def complete!
          response = gateway.purchase(transaction.amount.cents, tender)

          transaction.response = ActiveMerchant::Billing::Response.new(
            response.success?,
            response.message
          )
        end

        def cancel!
          return unless transaction.success?

          response = gateway.refund(transaction.amount.cents, tender)

          transaction.cancellation = ActiveMerchant::Billing::Response.new(
            response.success?,
            response.message
          )
        end
      end
    end
  end
end
```


### Capture

TODO: section introduction


#### Boilerplate

Start with the following boilerplate and customize it as necessary.
Refer to the inline annotations for guidance.

```ruby
# your_engine/app/models/workarea/payment/capture/your_tender_type.rb [1][2]
module Workarea
  class Payment
    module Capture
      class YourTenderType #[2]
        include OperationImplementation #[3]
        include YourTenderTypeOperation #[4]

        def complete! #[5]
          validate_reference! #[20]

          gateway_response = #[6]
            handle_gateway_errors do #[7]
              gateway.capture( #[21]
                transaction.amount.cents, #[22]
                transaction.reference.response.authorization
              )
            end

          transaction.response = #[10]
            ActiveMerchant::Billing::Response.new( #[11]
              gateway_response.success?, #[12]
              gateway_response.message
            )
        end

        def cancel! #[23]
          #noop
        end
      end
    end
  end
end
```

__[20]__
You must use `validate!_reference` to fulfill the operation implementation contract, unless this does not apply to your gateway for this operation.
See [Payment Tender Types](/articles/payment-tender-types.html).

__[21]__
Use the appropriate API call for your gateway, which is represented by `gateway` (see section [Gateways](#gateways_1)).
The correct API call is often `capture`, but refer to your gateway's documentation.

__[22]__
Pass the proper arguments for the gateway API call.
The first argument is typically the amount in cents.
The second argument is typically a reference to the original transaction's authorization, such as `transaction.reference.response.authorization` or `transaction.reference.response.params['transaction_id']`.
To construct this data, you have access to `transaction`, `tender`, and `options`.
See [Payment Tender Types](/articles/payment-tender-types.html).

__[23]__
For most gateways, it doesn't make sense to cancel a capture, so this method should be implemented to do nothing.
If however, there is an appropriate response for your gateway (e.g. Workarea PayPal issues a refund), you should implement it here, using other capture methods for inspiration.


#### Example

Here is a concrete example of a capture operation implementation used in production.

TODO: Replace with released code to ensure the GitHub link is stable.

[`Payment::Capture::GiftCard` from Workarea Gift Cards master branch](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/models/workarea/payment/capture/gift_card.rb):

```ruby
module Workarea
  class Payment
    class Capture
      class GiftCard
        include OperationImplementation
        include GiftCardOperation

        def complete!
          response = gateway.capture(transaction.amount.cents, tender)

          transaction.response = ActiveMerchant::Billing::Response.new(
            response.success?,
            response.message
          )
        end

        def cancel!
          # noop
        end
      end
    end
  end
end
```


### Refund

TODO: section introduction


#### Boilerplate

Start with the following boilerplate and customize it as necessary.
Refer to the inline annotations for guidance.

```ruby
# your_engine/app/models/workarea/payment/refund/your_tender_type.rb [1][2]
module Workarea
  class Payment
    module Refund
      class YourTenderType #[2]
        include OperationImplementation #[3]
        include YourTenderTypeOperation #[4]

        def complete! #[5]
          validate_reference! #[20]

          gateway_response = #[6]
            handle_gateway_errors do #[7]
              gateway.refund( #[24]
                transaction.amount.cents, #[22]
                transaction.reference.response.authorization
              )
            end

          transaction.response = #[10]
            ActiveMerchant::Billing::Response.new( #[11]
              gateway_response.success?, #[12]
              gateway_response.message
            )
        end

        def cancel! #[25]
          #noop
        end
      end
    end
  end
end
```

__[24]__
Use the appropriate API call for your gateway, which is represented by `gateway` (see section [Gateways](#gateways_1)).
The correct API call is often `refund`, but refer to your gateway's documentation.

__[25]__
For most gateways, it doesn't make sense to cancel a refund, so this method should be implemented to do nothing.
If however, there is an appropriate response for your gateway (e.g. Workarea Gift Card re-purchases the amount), you should implement it here, using other capture methods for inspiration.


#### Example

Here is a concrete example of a capture operation implementation used in production.

TODO: Replace with released code to ensure the GitHub link is stable.

[`Payment::Refund::GiftCard` from Workarea Gift Cards master branch](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/models/workarea/payment/refund/gift_card.rb):

```ruby
module Workarea
  class Payment
    class Refund
      class GiftCard
        include OperationImplementation
        include GiftCardOperation

        def complete!
          response = gateway.refund(transaction.amount.cents, tender)

          transaction.response = ActiveMerchant::Billing::Response.new(
            response.success?,
            response.message
          )
        end

        def cancel!
          return unless transaction.success?

          response = gateway.purchase(transaction.amount.cents, tender)

          transaction.cancellation = ActiveMerchant::Billing::Response.new(
            response.success?,
            response.message
          )
        end
      end
    end
  end
end
```


Tender Type Definition
----------------------------------------------------------------------

TODO: section


Payment Integration
----------------------------------------------------------------------

TODO: section


Storefront Integration
----------------------------------------------------------------------

TODO: section


Admin Integration
----------------------------------------------------------------------

TODO: section
