---
title: Implement a Primary Tender Type
excerpt: TODO
created_at: 2019/11/05
---

Implement a Primary Tender Type
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
          transaction.response = #[6][7]
            handle_gateway_errors do #[8]
              gateway.authorize( #[9]
                transaction.amount.cents, #[10]
                tender.foo,
                tender.bar
              )
            end
        end

        def cancel! #[11]
          return unless transaction.success? #[12]

          transaction.cancellation = #[13][7]
            handle_gateway_errors do #[8]
              gateway.void( #[14]
                transaction.response.authorization #[15]
              )
            end
        end
      end
    end
  end
end
```

__[1]__
Replace `your_engine` with the pathname for the root of your application or plugin, e.g. `~/workarea-deferred-pay`.

__[2]__
Replace `your_tender_type` and `YourTenderType` with the name of your tender type, e.g. `deferred_pay` and `DeferredPay`.

__[3]__
You must include this module to have access to `transaction`, `tender`, and `options`.
See [Payment Tender Types](/articles/payment-tender-types.html).

__[4]__
Replace `YourTenderTypeOperation` with the name of the module you created for your gateway, e.g. `DeferredPayOperation`.
See section [Gateways](#gateways_1).

__[5]__
You must implement `complete!` to fulfill the operation implementation contract.
See [Payment Tender Types](/articles/payment-tender-types.html).

__[6]__
You must assign `transaction.response` to fulfill the operation implementation contract.
See [Payment Tender Types](/articles/payment-tender-types.html).

__[7]__
The value assigned must be an object of type [`ActiveMerchant::Billing::Response`](https://www.rubydoc.info/gems/activemerchant/1.100.0/ActiveMerchant/Billing/Response).
Many gateways will return this type.
If yours doesn't, you'll have to initialize the instance yourself, and construct the arguments from the gateway's response.

Boilerplate for that scenario:

```ruby
gateway_response =
  handle_gateway_errors do
    gateway.authorize(
      transaction.amount.cents,
      tender.foo,
      tender.bar
    )
  end

transaction.response =
  ActiveMerchant::Billing::Response.new(
    gateway_response.success?,
    gateway_response.message
  )
```

__[8]__
You should handle gateway exceptions.
You should have implemented `handle_gateway_errors` for your gateway.
See section [Gateways](#gateways_1).

__[9]__
Use the appropriate API call for your gateway, which is represented by `gateway` (see section [Gateways](#gateways_1)).
The correct API call is often `authorize`, but refer to your gateway's documentation.

__[10]__
Pass the proper arguments for the gateway API call.
The first argument is typically the amount in cents.
To construct this data, you have access to `transaction`, `tender`, and `options`.
See [Payment Tender Types](/articles/payment-tender-types.html).

__[11]__
You must implement `cancel!` to fulfill the operation implementation contract.
See [Payment Tender Types](/articles/payment-tender-types.html).

__[12]__
You must return early if the transaction wasn't successful to fulfill the operation implementation contract.
See [Payment Tender Types](/articles/payment-tender-types.html).

__[13]__
You must assign `transaction.cancellation` to fulfill the operation implementation contract.
See [Payment Tender Types](/articles/payment-tender-types.html).

__[14]__
Use the appropriate API call for your gateway, which is represented by `gateway` (see section [Gateways](#gateways_1)).
The correct API call is often `void`, `cancel`, or `refund`, but refer to your gateway's documentation.

__[15]__
Pass the proper arguments for the gateway API call.
The first argument is typically a reference to the original authorization, such as `transaction.response.authorization` or `transaction.response.params['transaction_id']`.
To construct this data, you have access to `transaction`, `tender`, `options`, and `address`.
See [Payment Tender Types](/articles/payment-tender-types.html).


#### Example

Here is a concrete example of an authorize operation implementation used in production.

[`Payment::Authorize::Paypal` from Workarea PayPal 2.0.8](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/models/workarea/payment/authorize/paypal.rb):

```ruby
module Workarea
  class Payment
    module Authorize
      class Paypal
        include OperationImplementation
        include CreditCardOperation

        delegate :gateway, to: Workarea::Paypal

        def complete!
          transaction.response = handle_active_merchant_errors do
            gateway.authorize(
              transaction.amount.cents,
              token: tender.token,
              payer_id: tender.payer_id,
              currency: transaction.amount.currency
            )
          end
        end

        def cancel!
          return unless transaction.success?

          transaction.cancellation = handle_active_merchant_errors do
            gateway.void(transaction.response.params['transaction_id'])
          end
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
          transaction.response = #[6][7]
            handle_gateway_errors do #[8]
              gateway.purchase( #[16]
                transaction.amount.cents, #[10]
                tender.foo,
                tender.bar
              )
            end
        end

        def cancel! #[11]
          return unless transaction.success? #[12]

          transaction.cancellation = #[13][7]
            handle_gateway_errors do #[8]
              gateway.void( #[14]
                transaction.response.authorization #[15]
              )
            end
        end
      end
    end
  end
end
```

__[16]__
Use the appropriate API call for your gateway, which is represented by `gateway` (see section [Gateways](#gateways_1)).
The correct API call is often `purchase`, but refer to your gateway's documentation.


#### Example

Here is a concrete example of a purchase operation implementation used in production.

[`Payment::Purchase::Paypal` from Workarea PayPal 2.0.8](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/models/workarea/payment/purchase/paypal.rb):

```ruby
module Workarea
  class Payment
    module Purchase
      class Paypal
        include OperationImplementation
        include CreditCardOperation

        delegate :gateway, to: Workarea::Paypal

        def complete!
          transaction.response = handle_active_merchant_errors do
            gateway.purchase(
              transaction.amount.cents,
              token: tender.token,
              payer_id: tender.payer_id,
              currency: transaction.amount.currency
            )
          end
        end

        def cancel!
          return unless transaction.success?

          transaction.cancellation = handle_active_merchant_errors do
            gateway.void(transaction.response.params['transaction_id'])
          end
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
          validate_reference! #[17]

          transaction.response = #[6][7]
            handle_gateway_errors do #[8]
              gateway.capture( #[18]
                transaction.amount.cents, #[19]
                transaction.reference.response.authorization
              )
            end
        end

        def cancel! #[20]
          #noop
        end
      end
    end
  end
end
```

__[17]__
You must use `validate!_reference` to fulfill the operation implementation contract, unless this does not apply to your gateway for this operation.
See [Payment Tender Types](/articles/payment-tender-types.html).

__[18]__
Use the appropriate API call for your gateway, which is represented by `gateway` (see section [Gateways](#gateways_1)).
The correct API call is often `capture`, but refer to your gateway's documentation.

__[19]__
Pass the proper arguments for the gateway API call.
The first argument is typically the amount in cents.
The second argument is typically a reference to the original transaction's authorization, such as `transaction.reference.response.authorization` or `transaction.reference.response.params['transaction_id']`.
To construct this data, you have access to `transaction`, `tender`, and `options`.
See [Payment Tender Types](/articles/payment-tender-types.html).

__[20]__
For most gateways, it doesn't make sense to cancel a capture, so this method should be implemented to do nothing.
If however, there is an appropriate response for your gateway (e.g. Workarea PayPal issues a refund), you should implement it here, using other capture methods for inspiration.


#### Example

Here is a concrete example of a capture operation implementation used in production.

[`Payment::Capture::Paypal` from Workarea PayPal 2.0.8](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/models/workarea/payment/capture/paypal.rb):

```ruby
module Workarea
  class Payment
    class Capture
      class Paypal
        include OperationImplementation
        include CreditCardOperation

        delegate :gateway, to: Workarea::Paypal

        def complete!
          validate_reference!

          transaction.response = handle_active_merchant_errors do
            gateway.capture(
              transaction.amount.cents,
              transaction.reference.response.params['transaction_id'],
              currency: transaction.amount.currency
            )
          end
        end

        def cancel!
          return unless transaction.success?

          transaction.cancellation = handle_active_merchant_errors do
            gateway.refund(
              transaction.amount.cents,
              transaction.response.params['transaction_id']
            )
          end
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
    module Capture
      class YourTenderType #[2]
        include OperationImplementation #[3]
        include YourTenderTypeOperation #[4]

        def complete! #[5]
          validate_reference! #[17]

          transaction.response = #[6][7]
            handle_gateway_errors do #[8]
              gateway.refund( #[21]
                transaction.amount.cents, #[19]
                transaction.reference.response.authorization
              )
            end
        end

        def cancel! #[22]
          #noop
        end
      end
    end
  end
end
```

__[21]__
Use the appropriate API call for your gateway, which is represented by `gateway` (see section [Gateways](#gateways_1)).
The correct API call is often `refund`, but refer to your gateway's documentation.

__[22]__
For most gateways, it doesn't make sense to cancel a refund, so this method should be implemented to do nothing.
If however, there is an appropriate response for your gateway (e.g. Workarea Gift Card re-purchases the amount), you should implement it here, using other capture methods for inspiration.


#### Example

Here is a concrete example of a capture operation implementation used in production.

[`Payment::Refund::Paypal` from Workarea PayPal 2.0.8](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/models/workarea/payment/refund/paypal.rb):

```ruby
module Workarea
  class Payment
    class Refund
      class Paypal
        include OperationImplementation
        include CreditCardOperation

        def complete!
          validate_reference!

          transaction.response = handle_active_merchant_errors do
            Workarea::Paypal.gateway.refund(
              transaction.amount.cents,
              transaction.reference.response.params['transaction_id'],
              currency: transaction.amount.currency
            )
          end
        end

        def cancel!
          # noop
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
