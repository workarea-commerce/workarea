---
title: Implement the Credit Card Tender Type
excerpt: TODO
created_at: 2019/10/25
---

Implement the Credit Card Tender Type
======================================================================

[The credit card tender type](/articles/payment-tender-types.html#credit-card-tender-type_2) is a [payment tender type](/articles/payment-tender-types.html) included in base, but incomplete.
You must fully implement this tender type in order to accept credit card payments in production.
For many payment providers, you can install a Workarea plugin that completes the implementation for you.

However, a retailer may choose a payment service provider for which no Workarea plugin is available, or you may be tasked with writing the plugin for a particular provider.
In either case, you can complete the credit card tender type implementation in the following steps:

1. [Implement gateways](#gateways_1)
2. [Implement credit card tokenization](#credit-card-tokenization_2)
3. [Implement each payment operation](#operation-implementations_3)

The following sections cover each step in greater depth and provide examples from
_Workarea Core_ v3.4.18 (
[gem](https://rubygems.org/gems/workarea-core/versions/3.4.18),
[docs](https://www.rubydoc.info/gems/workarea-core/3.4.18),
[source](https://github.com/workarea-commerce/workarea/tree/v3.4.18/core)
)
and
_Workarea Braintree_ v1.0.3 (
[gem](https://rubygems.org/gems/workarea-braintree/versions/1.0.3),
[docs](https://www.rubydoc.info/gems/workarea-braintree/1.0.3),
[source](https://github.com/workarea-commerce/workarea-braintree/tree/v1.0.3)
).


Gateways
----------------------------------------------------------------------

[Implementing Payment Tender Types, Gateways](/articles/implementing-payment-tender-types.html#gateways_1).

The base credit card tender type uses a bogus gateway.
[`ActiveMerchant::Billing::BogusGateway`](https://www.rubydoc.info/gems/activemerchant/1.99.0/ActiveMerchant/Billing/BogusGateway).
Which is [initialized and memoized in configuration](https://github.com/workarea-commerce/workarea/blob/v3.4.18/core/config/initializers/11_payment.rb#L6).
This is a [gateway anti-pattern](/articles/implementing-payment-tender-types.html#gateway-anti-patterns_3).
Use a current [gateway pattern](/articles/implementing-payment-tender-types.html#gateway-patterns_2) instead.

The gateway is accessed via the `#gateway` method in a module that's mixed into objects that need access to the gateway.
[`Payment::CreditCardOperation`](https://github.com/workarea-commerce/workarea/blob/master/core/app/models/workarea/payment/credit_card_operation.rb).
[`Payment::CreditCardOperation#gateway`](https://github.com/workarea-commerce/workarea/blob/master/core/app/models/workarea/payment/credit_card_operation.rb#L15-L17)
The method returns the memoized gateway.
Again, this is an anti-pattern. If you use this access pattern, design the method to init a new instance each time.

Apps need a gateway that connects to an actual payment service provider.
The service must support credit card tokenization to be compatible with Workarea.
See section [Credit Card Tokenization](#credit-card-tokenization_2).

The Workarea Braintree plugin integrates Workarea with the [Braintree](https://www.braintreepayments.com/) payment service.

Workarea Braintree relies on two gateway classes.
[`ActiveMerchant::Billing::BraintreeGateway`](https://www.rubydoc.info/gems/activemerchant/1.99.0/ActiveMerchant/Billing/BraintreeGateway).
[`ActiveMerchant::Billing::BogusBraintreeGateway`](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/lib/active_merchant/billing/bogus_braintree_gateway.rb).

The first is used to communicate with the remote Braintree payment service.
This is used in production, initialized with production credentials from secrets.
Plugin supports using this gateway in additional environments; any in which you have secrets.
To use the braintree service with Commerce Cloud, you'd also have to update the proxy configuration to allow outgoing requests to the Braintree service.
See [Implementing Payment Tender Types, Commerce Cloud Proxy](/articles/implementing-payment-tender-types.html#commerce-cloud-proxy_4).

This class is also used for automated tests, although the responses have all been recorded as vcr cassettes, so doesn't go over the network.
Initialized with "dummy" credentials.
See [Implementing Payment Tender Types, Gateway Patterns](/articles/implementing-payment-tender-types.html#gateway-patterns_2).

The second class, the bogus gateway, does not communicate over the network
Used for local development and testing and any environment for which you don't have Braintree credentials set up.
The class is provided by the plugin; it extends Active Merchant.
Doesn't include tests, but it should.

Within operation implementations and credit card tokenization, Workarea Braintree relies on the credit card operation mixin from base to access the gateway.
See [Implementing Payment Tender Types, Gateway Patterns](/articles/implementing-payment-tender-types.html#gateway-patterns_2).
But to use its own gateway instances, it reconfigures some things when the app boots.
It has [autoconfiguration code](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/lib/workarea/braintree.rb#L8-L24), which is called from an [initializer](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/config/initializers/workarea.rb#L1).
The effect is that in any environment where there are braintree secrets, you get a "real" Braintree endpoint.
Otherwise, you get a bogus gateway thate doesn't go over the network.
Beware that this uses the memoized gateway anti-pattern.
[Implementing Payment Tender Types, Gateway Anti-Patterns](/articles/implementing-payment-tender-types.html#gateway-anti-patterns_3).
Use a current gateway pattern instead.

For automated testing, Workarea Braintree implements its own test mixin [`BraintreeGatewayVCRConfig`](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/test/support/workarea/braintree_support_vcr_config.rb), which implements `#gateway` and is mixed into all automated tests that need to communicate with Braintree.
The module assigns a new/different instance of [`ActiveMerchant::Billing::BraintreeGateway`](https://www.rubydoc.info/gems/activemerchant/1.99.0/ActiveMerchant/Billing/BraintreeGateway) as the credit card gateway in configuration.
It uses bogus creds, which is fine because all the requests have already been recorded as [VCR cassettes](https://github.com/workarea-commerce/workarea-braintree/tree/v1.0.3/test/vcr_cassettes).
Example: the plugin [decorates `Payment::CreditCardIntegrationTest`](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/test/models/workarea/payment/credit_card_integration_test.decorator), mixing in the module so that all requests to the gateway are now returned from the vcr cassettes.
if you are implementing a new cc gateway from scratch, you can follow this pattern by using a "real" gateway for testing
until all the tests pass and then commit the casettes and remove your credentials from your test setup.


Credit Card Tokenization
----------------------------------------------------------------------

In addition to processing payments, a credit card gateway is responsible for [credit card tokenization](/articles/implementing-payment-tender-types.html#credit-card-tokenization_5).
Workarea encapsulates its tokenization logic within `Payment::StoreCreditCard`, particularly `Payment::StoreCreditCard#perform!` (with tests in `Payment::StoreCreditCardTest`).

If your gateway's tokenization API differs from Workarea's default implementation, decorate `Payment::StoreCreditCard` to customize the implementation as necessary.

The default implementation of `#perform!` assumes the gateway responds to `#store`, returns the token in the param `billingid` and will potentially raise `ActiveMerchant::ResponseError`, `ActiveMerchant::ActiveMerchantError`, or `ActiveMerchant::ConnectionError` (encapsulated by `handle_active_merchant_error`).
The full implementation follows
([source](https://github.com/workarea-commerce/workarea/blob/v3.4.18/core/app/models/workarea/payment/store_credit_card.rb)):

```ruby
module Workarea
  class Payment
    class StoreCreditCard
      def perform!
        return true if @credit_card.token.present?

        response = handle_active_merchant_errors do
          gateway.store(@credit_card.to_active_merchant)
        end

        @credit_card.token = response.params['billingid']

        response.success?
      end
    end
  end
end
```

Change the aspects that differ for your gateway.
For example, the Braintree gateway returns the card token within a different parameter
([source](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/app/models/workarea/payment/store_credit_card.decorator)):

```ruby
module Workarea
  decorate Payment::StoreCreditCard, with: :braintree do
    def perform!
      # ...
      @credit_card.token = response.params['credit_card_token']
    end
  end
end
```

Workarea Braintree also decorates tests to configure the correct gateway and account for gateway API differences.
Refer to the following sources:

* [Workarea Core implementation](https://github.com/workarea-commerce/workarea/blob/v3.4.18/core/app/models/workarea/payment/store_credit_card.rb)
* [Workarea Core test case](https://github.com/workarea-commerce/workarea/blob/v3.4.18/core/test/models/workarea/payment/store_credit_card_test.rb)
* [Workarea Braintree implementation extensions](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/app/models/workarea/payment/store_credit_card.decorator)
* [Workarea Braintree test case extensions](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/test/models/workarea/payment/store_credit_card_test.decorator)


Operation Implementations
----------------------------------------------------------------------

Introduction to this section.
[Operation Implementations](/articles/implementing-payment-tender-types.html#operation-implementations_8)
Code annotations using running numbers.
In an explain doc, explain the semantics of each operation.


### Authorize


#### Boilerplate

```ruby
# your_engine/app/models/workarea/payment/authorize/credit_card.decorator [1]

module Workarea
  decorate Payment::Authorize::CreditCard, with: :your_engine do #[2]
    private

    def transaction_options #[3]
      {
        order_id: tender.payment.id, #[4]
        foo: 'bar',
        baz: 'qux'
      }
    end
  end
end
```

__[1]__
Replace `your_engine` with the pathname for the root of your application or plugin, e.g. ...

__[2]__
TODO

__[3]__
TODO

__[4]__
TODO


```ruby
# your_engine/app/models/workarea/payment/authorize/credit_card.decorator [1]

module Workarea
  decorate Payment::Authorize::CreditCard, with: :your_engine do #[2]
    def complete!
      return unless StoreCreditCard.new(tender, options).save!

      transaction.response =
        handle_active_merchant_errors do
          gateway.authorize(
            transaction.amount.cents,
            tender.to_token_or_active_merchant,
            transaction_options
          )
        end
    end

    private

    def transaction_options #[3]
      {
        order_id: tender.payment.id, #[4]
        foo: 'bar',
        baz: 'qux'
      }
    end
  end
end
```

```ruby
# your_engine/app/models/workarea/payment/authorize/credit_card.decorator [1]

module Workarea
  decorate Payment::Authorize::CreditCard, with: :your_engine do #[2]
    def complete!
      transaction.response =
        handle_active_merchant_errors do
          if tender.token.present?
            gateway.authorize(
              transaction.amount.cents,
              tender.token,
              transaction_options
            )
          else
            gateway.authorize(
              transaction.amount.cents,
              tender.to_active_merchant,
              transaction_options
            )
          end
        end

      if transaction.response.success? && tender.token.blank?
        tender.token =
          transaction.response.params['credit_card']['token']
        tender.save!
      end
    end

    def cancel!
      return unless transaction.success?

      transaction.cancellation =
        handle_active_merchant_errors do
          gateway.void(transaction.response.authorization)
        end
    end

    private

    def transaction_options #[3]
      {
        order_id: tender.payment.id, #[4]
        foo: 'bar',
        baz: 'qux'
      }
    end
  end
end
```

__[1]__
Replace `your_engine` with the pathname for the root of your application or plugin, e.g. ...

__[2]__
Replace `your_tender_type` and `YourTenderType` with the name of your tender type, e.g. ...

__[3]__
provides the basic contract/abstraction for an operation implementation.
gets you `#tender`, `#transaction`, `#options`, which you'll need to implement `#complete!` and `#cancel!`.

__[4]__
Replace `YourTenderTypeOperation` with the name of the module you created earlier ...
gets you `#gateway` and exception handling for your gateway, e.g. `handle_active_merchant_errors` or `handle_gateway_errors`.

__[5]__
You must implement `complete!`.

__[6]__
You must assign `transaction.response`.

__[7]__
The value assigned must be an object of type [`ActiveMerchant::Billing::Response`](https://www.rubydoc.info/gems/activemerchant/1.100.0/ActiveMerchant/Billing/Response).
Many gateways will return this type.
If yours doesn't, you'll have to initialize the instance yourself, and construct the arguments from the gateway's response.

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
The module you wrote earlier included `handle_gateway_errors`, which accepts a block.
Wrap that around the code that communicates with the gateway.

__[9]__
Use the right API call for your gateway, but usually authorize.

__[10]__
Pass the proper arguments for the API call.
The first arg is typically the amount in cents.
The args are derived from transaction, tender, and options (the operation implementation is initialized with these).

__[11]__
You must implement `cancel!`.

__[12]__
You must return early if the transaction wasn't successful (nothing to cancel).

__[13]__
You must assign `transaction.cancellation`.

__[14]__
Use the right API call for your gateway, but usually void, cancel, or refund.

__[15]__
Pass the proper arguments for the API call.
The first arg is typically a reference to the original authorization.
e.g. `transaction.response.authorization` or `transaction.response.params['transaction_id']`
The args are derived from transaction, tender, and options (the operation implementation is initialized with these).


#### Example

[Workarea Core implementation](https://github.com/workarea-commerce/workarea/blob/v3.4.18/core/app/models/workarea/payment/authorize/credit_card.rb)

[Workarea Core test case](https://github.com/workarea-commerce/workarea/blob/v3.4.18/core/test/models/workarea/payment/authorize/credit_card_test.rb)

[Workarea Braintree implementation extensions](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/app/models/workarea/payment/authorize/credit_card.decorator)

[Workarea Braintree test case extensions](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/test/models/workarea/payment/authorize/credit_card_test.decorator)


### Purchase


#### Boilerplate (Simple)

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
Use the right API call for your gateway, but usually purchase.
Pass the proper arguments for that API call.
The first arg is typically the amount in cents.
The args are derived from transaction, tender, and options (the operation implementation is initialized with these).


#### Boilerplate

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
Use the right API call for your gateway, but usually purchase.
Pass the proper arguments for that API call.
The first arg is typically the amount in cents.
The args are derived from transaction, tender, and options (the operation implementation is initialized with these).


#### Example

[Workarea Core implementation](https://github.com/workarea-commerce/workarea/blob/v3.4.18/core/app/models/workarea/payment/purchase/credit_card.rb)

[Workarea Core test case](https://github.com/workarea-commerce/workarea/blob/v3.4.18/core/test/models/workarea/payment/purchase/credit_card_test.rb)

[Workarea Braintree implementation extensions](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/app/models/workarea/payment/purchase/credit_card.decorator)

[Workarea Braintree test case extensions](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/test/models/workarea/payment/purchase/credit_card_test.decorator)


### Capture


#### Boilerplate

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
A capture operation often references the original authorization transaction.
If this applies to your gateway, then validate the reference with `validate!_reference`.
This method comes from `Payment::OperationImplementation`.
Omit this API call if your gateway doesn't rely on a reference transaction.

__[18]__
Use the right API call for your gateway, but usually capture.

__[19]__
Pass the proper arguments for the API call.
The first arg is typically the amount in cents.
The second arg is typically something that identifies the reference transaction
e.g. `transaction.reference.response.authorization` or `transaction.reference.response.params['transaction_id']`.
The args are derived from transaction, tender, and options (the operation implementation is initialized with these).

__[20]__
For most gateways, it doesn't make sense to cancel capture, so this method should be implemented to do nothing.
If however, there is an appropriate response for your gateway (e.g. PayPal issues a refund), you should implement it here, using other capture methods for inspiration.


#### Example

[Workarea Core implementation](https://github.com/workarea-commerce/workarea/blob/v3.4.18/core/app/models/workarea/payment/capture/credit_card.rb)

[Workarea Core test case](https://github.com/workarea-commerce/workarea/blob/v3.4.18/core/test/models/workarea/payment/capture/credit_card_test.rb)

[Workarea Braintree implementation extensions](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/app/models/workarea/payment/capture/credit_card.decorator)

[Workarea Braintree test case extensions](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/test/models/workarea/payment/capture/credit_card_test.decorator)


### Refund


#### Boilerplate

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
Use the right API call for your gateway, but usually refund.

__[22]__
For most gateways, it doesn't make sense to cancel a refund, so this method should be implemented to do nothing.
If however, there is an appropriate response for your gateway (e.g. Gift Card re-purchases the amount), you should implement it here, using other capture methods for inspiration.


#### Example

[Workarea Core implementation](https://github.com/workarea-commerce/workarea/blob/v3.4.18/core/app/models/workarea/payment/refund/credit_card.rb)

[Workarea Core test case](https://github.com/workarea-commerce/workarea/blob/v3.4.18/core/test/models/workarea/payment/refund/credit_card_test.rb)

[Workarea Braintree implementation extensions](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/app/models/workarea/payment/refund/credit_card.decorator)

[Workarea Braintree test case extensions](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/test/models/workarea/payment/refund/credit_card_test.decorator)


Storefront Integration
----------------------------------------------------------------------

