---
title: Implement the Credit Card Tender Type
excerpt: TODO
created_at: 2019/11/05
---

Implement the Credit Card Tender Type
======================================================================

TODO: document introduction


Gateways
----------------------------------------------------------------------

TODO: section


Credit Card Tokenization
----------------------------------------------------------------------

TODO: section


Operation Implementations
----------------------------------------------------------------------

TODO: section introduction

_Explain_ operation implementations in the [Payment Tender Types](/articles/payment-tender-types.html) explain doc.


### Authorize

TODO: section introduction


#### Base Implementation

The authorize operation implementation for the credit card tender type is already implemented in base.

[`Payment::Authorize::CreditCard` from Workarea Core 3.4.20](https://github.com/workarea-commerce/workarea/blob/v3.4.20/core/app/models/workarea/payment/authorize/credit_card.rb):

```ruby
module Workarea
  class Payment
    module Authorize
      class CreditCard
        include OperationImplementation
        include CreditCardOperation

        delegate :address, to: :tender

        def complete!
          return unless StoreCreditCard.new(tender, options).save!

          transaction.response = handle_active_merchant_errors do
            gateway.authorize(
              transaction.amount.cents,
              tender.to_token_or_active_merchant,
              transaction_options
            )
          end
        end

        def cancel!
          return unless transaction.success?

          transaction.cancellation = handle_active_merchant_errors do
            gateway.void(transaction.response.authorization)
          end
        end

        private

        def transaction_options
          {}
        end
      end
    end
  end
end
```

You can decorate it to customize it.

You can start with simple boilerplate or full boilerplate.


#### Decorator Boilerplate (Simple)

Use this if you can get away with customizing the `transaction_options` only.

Start with the following boilerplate and customize it as necessary.
Refer to the inline annotations for guidance.

```ruby
# your_engine/app/models/workarea/payment/authorize/credit_card.decorator [1]

module Workarea
  decorate Payment::Authorize::CreditCard, with: :your_engine do #[1][2]
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
Replace `your_engine` with the pathname/slug for your application or plugin, e.g. `~/workarea-processor-pro` and `processor_pro`.

__[2]__
The `with` argument is necessary for plugins, but you can omit it if you are decorating from an application.

__[3]__
Implement `transaction_options` to return a hash containing the data required by your gateway.

__[4]__
To construct this data, you have access to `transaction`, `tender`, `options`, and `address`.
See [Payment Tender Types](/articles/payment-tender-types.html).


#### Decorator Boilerplate (Full)

Use this if you have to change `complete!` or `cancel!` for your gateway.

Start with the following boilerplate and customize it as necessary.
Refer to the inline annotations for guidance.

```ruby
# your_engine/app/models/workarea/payment/authorize/credit_card.decorator [1]

module Workarea
  decorate Payment::Authorize::CreditCard, with: :your_engine do #[1][2]
    def complete! #[5]
      return unless StoreCreditCard.new(tender, options).save! #[6]

      transaction.response = #[7][8]
        handle_active_merchant_errors do #[9]
          gateway.authorize( #[10]
            transaction.amount.cents, #[11]
            tender.to_token_or_active_merchant,
            transaction_options #[12]
          )
        end
    end

    def cancel! #[13]
      return unless transaction.success? #[14]

      transaction.cancellation = #[15]
        handle_active_merchant_errors do #[8]
          gateway.void( #[16]
            transaction.response.authorization #[17]
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

__[5]__
If necessary for your gateway, re-implement `complete!`.
Refer to additional annotations for details.

__[6]__
You must tokenize the credit card and persist the token for future use.
You can do this in a dedicated request to the gateway using `StoreCreditCard#save` (see section [Credit Card Tokenization](#credit-card-tokenization_2)).
Or, if supported by your gateway, you can tokenize in the same request as the authorization.
If you do so, you must save the token after the authorize request succeeds.

Boilerplate for that scenario:

```ruby
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
```

__[7]__
You must assign `transaction.response`.

__[8]__
The value assigned must be an object of type [`ActiveMerchant::Billing::Response`](https://www.rubydoc.info/gems/activemerchant/1.100.0/ActiveMerchant/Billing/Response).
Active Merchant gateways should return this type.
If your gateway isn't Active Merchant and doesn't return this type of object, you'll have to initialize the instance yourself, and construct the arguments from the gateway's response.

Boilerplate for that scenario:

```ruby
gateway_response =
  handle_active_merchant_errors do
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

__[9]__
You should handle gateway exceptions.
You can use `handle_active_merchant_errors` from the base implementation for Active Merchant gateways.
If your gateway is not Active Merchant, you may need to implement your own error handling.

__[10]__
Use the appropriate API call for your gateway, which is represented by `gateway` (see section [Gateways](#gateways_1)).
The correct API call is often `authorize`, but refer to your gateway's documentation.

__[11]__
Pass the proper arguments for the gateway API call.
The first argument is typically the amount in cents.
To construct this data, you have access to `transaction`, `tender`, `options`, and `address`.
See [Payment Tender Types](/articles/payment-tender-types.html).

__[12]__
Continue to use `transaction_options` if it makes sense for your gateway.
Transaction options are introduced in section [Authorize, Boilerplate (Simple)](#boilerplate-simple_5).

__[13]__
If necessary for your gateway, re-implement `cancel!`, which is part of the operation implementation contract.
See [Payment Tender Types](/articles/payment-tender-types.html).
Refer to additional annotations for details.

__[14]__
You must return early if the transaction wasn't successful to fulfill the operation implementation contract.
See [Payment Tender Types](/articles/payment-tender-types.html).

__[15]__
You must assign `transaction.cancellation` to fulfill the operation implementation contract.
See [Payment Tender Types](/articles/payment-tender-types.html).

__[16]__
Use the appropriate API call for your gateway, which is represented by `gateway` (see section [Gateways](#gateways_1)).
The correct API call is often `void` or `cancel`, but refer to your gateway's documentation.

__[17]__
Pass the proper arguments for the gateway API call.
The first argument is typically a reference to the original authorization.
To construct this data, you have access to `transaction`, `tender`, `options`, and `address`.
See [Payment Tender Types](/articles/payment-tender-types.html).


#### Decorator Example

Here is a concrete example of an authorize operation implementation decorator used in production.

[`Payment::Authorize::CreditCard` decorator from Workarea Braintree 1.0.3](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/app/models/workarea/payment/authorize/credit_card.decorator):

```ruby
module Workarea
  decorate Payment::Authorize::CreditCard, with: :braintree do
    decorated { delegate :address, to: :tender }

    def complete!
      transaction.response = handle_active_merchant_errors do
        if tender.token.present?
          gateway.authorize(
            transaction.amount.cents,
            tender.token,
            {
              payment_method_token: true,
              order_id: order_id,
              email: email,
              billing_address: billing_address
            }
          )
        else
          gateway.authorize(
            transaction.amount.cents,
            tender.to_active_merchant,
            {
              store: true,
              order_id: order_id,
              email: email,
              billing_address: billing_address
            }
          )
        end
      end

      if transaction.response.success? && tender.token.blank?
        tender.token = transaction.response.params["braintree_transaction"]["credit_card_details"]["token"]
        tender.save!
      end
    end

    def cancel!
      return unless transaction.success?

      transaction.cancellation = handle_active_merchant_errors do
        gateway.void(transaction.response.authorization)
      end
    end

    private

    def email
      return unless tender.profile.present?

      tender.profile.email
    end

    def order_id
      tender.payment.id
    end

    def billing_address
      {
        name:       nil,
        company:    nil,
        address1:   address.street,
        address2:   address.street_2,
        city:       address.city,
        state:      address.region,
        country:    address.country.try(:alpha2),
        zip:        address.postal_code,
        phone:      nil
      }
    end
  end
end
```


### Purchase

TODO: section introduction


#### Base Implementation

The purchase operation implementation for the credit card tender type is already implemented in base.

[`Payment::Purchase::CreditCard` from Workarea Core 3.4.20](https://github.com/workarea-commerce/workarea/blob/v3.4.20/core/app/models/workarea/payment/purchase/credit_card.rb):

```ruby
module Workarea
  class Payment
    module Purchase
      class CreditCard
        include OperationImplementation
        include CreditCardOperation

        delegate :address, to: :tender

        def complete!
          return unless StoreCreditCard.new(tender, options).save!

          transaction.response = handle_active_merchant_errors do
            gateway.purchase(
              transaction.amount.cents,
              tender.to_token_or_active_merchant,
              transaction_options
            )
          end
        end

        def cancel!
          return unless transaction.success?

          transaction.cancellation = handle_active_merchant_errors do
            gateway.void(transaction.response.authorization)
          end
        end

        private

        def transaction_options
          {}
        end
      end
    end
  end
end
```

You can decorate this to customize it.

You can start with simple boilerplate or full boilerplate.


#### Decorator Boilerplate (Simple)

Use this if you can get away with customizing the `transaction_options` only.

Start with the following boilerplate and customize it as necessary.
Refer to the inline annotations for guidance.

```ruby
# your_engine/app/models/workarea/payment/purchase/credit_card.decorator [1]

module Workarea
  decorate Payment::Purchase::CreditCard, with: :your_engine do #[1][2]
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


#### Decorator Boilerplate (Full)

Use this if you have to change `complete!` or `cancel!` for your gateway.

Start with the following boilerplate and customize it as necessary.
Refer to the inline annotations for guidance.

```ruby
# your_engine/app/models/workarea/payment/purchase/credit_card.decorator [1]

module Workarea
  decorate Payment::Purchase::CreditCard, with: :your_engine do #[1][2]
    def complete! #[5]
      return unless StoreCreditCard.new(tender, options).save! #[6]

      transaction.response = #[7][8]
        handle_active_merchant_errors do #[9]
          gateway.purchase( #[18]
            transaction.amount.cents, #[11]
            tender.to_token_or_active_merchant,
            transaction_options #[12]
          )
        end
    end

    def cancel! #[13]
      return unless transaction.success? #[14]

      transaction.cancellation = #[15]
        handle_active_merchant_errors do #[8]
          gateway.void( #[16]
            transaction.response.authorization #[17]
          )
        end
    end

    private

    def transaction_options #[3][12]
      {
        order_id: tender.payment.id, #[4]
        foo: 'bar',
        baz: 'qux'
      }
    end
  end
end
```

__[18]__
Use the appropriate API call for your gateway, which is represented by `gateway` (see section [Gateways](#gateways_1)).
The correct API call is often `purchase`, but refer to your gateway's documentation.


#### Decorator Example

Here is a concrete example of a purchase operation implementation decorator used in production.

[`Payment::Purchase::CreditCard` decorator from Workarea Braintree 1.0.3](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/app/models/workarea/payment/purchase/credit_card.decorator):

```ruby
module Workarea
  decorate Payment::Purchase::CreditCard, with: :braintree do
    decorated { delegate :address, to: :tender }

    def complete!
      transaction.response = handle_active_merchant_errors do
        if tender.token.present?
          gateway.purchase(
            transaction.amount.cents,
            tender.token,
            { payment_method_token: true }
          )
        else
          gateway.purchase(
            transaction.amount.cents,
            tender.to_active_merchant,
            { store: true, billing_address: billing_address }
          )
        end
      end

      if transaction.response.success? && tender.token.blank?
        tender.token = transaction.response.params["braintree_transaction"]["credit_card_details"]["token"]
        tender.save!
      end
    end

    def cancel!
      return unless transaction.success?

      transaction.cancellation = handle_active_merchant_errors do
        gateway.void(transaction.response.authorization)
      end
    end

    private

    def billing_address
      {
        name:       nil,
        company:    nil,
        address1:   address.street,
        address2:   address.street_2,
        city:       address.city,
        state:      address.region,
        country:    address.country.try(:alpha2),
        zip:        address.postal_code,
        phone:      nil
      }
    end
  end
end
```

### Capture

TODO: section introduction


#### Base Implementation

The capture operation implementation for the credit card tender type is already implemented in base.

[`Payment::Capture::CreditCard` from Workarea Core 3.4.20](https://github.com/workarea-commerce/workarea/blob/v3.4.20/core/app/models/workarea/payment/capture/credit_card.rb):

```ruby
module Workarea
  class Payment
    class Capture
      class CreditCard
        include OperationImplementation
        include CreditCardOperation

        def complete!
          validate_reference!

          transaction.response = handle_active_merchant_errors do
            gateway.capture(
              transaction.amount.cents,
              transaction.reference.response.authorization
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

You can decorate it to customize it.


#### Decorator Boilerplate

Start with the following boilerplate and customize it as necessary.
Refer to the inline annotations for guidance.

```ruby
# your_engine/app/models/workarea/payment/capture/credit_card.decorator [1]

module Workarea
  decorate Payment::Capture::CreditCard, with: :your_engine do #[1][2]
    def complete! #[5]
      validate_reference! #[19]

      transaction.response = #[7][8]
        handle_active_merchant_errors do #[9]
          gateway.capture( #[20]
            transaction.amount.cents, #[21]
            transaction.reference.response.authorization
          )
        end
    end

    # def cancel! #[22]
    # end
  end
end
```

__[19]__
You must use `validate!_reference` to fulfill the operation implementation contract, unless this does not apply to your gateway for this operation.
See [Payment Tender Types](/articles/payment-tender-types.html).

__[20]__
Use the appropriate API call for your gateway, which is represented by `gateway` (see section [Gateways](#gateways_1)).
The correct API call is often `capture`, but refer to your gateway's documentation.

__[21]__
Pass the proper arguments for the gateway API call.
The first argument is typically the amount in cents.
The second argument is typically a reference to the original transaction's authorization.
To construct this data, you have access to `transaction`, `tender`, `options`, and `address`.
See [Payment Tender Types](/articles/payment-tender-types.html).

__[22]__
For a credit card capture, there is nothing to cancel, so this is implemented as a noop in the base implementation.
However, if your gateway provides an appropriate API call, use it here instead.


#### Decorator Example

Here is a concrete example of a capture operation implementation decorator used in production.

[`Payment::Capture::CreditCard` decorator from Workarea Braintree 1.0.3](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/app/models/workarea/payment/capture/credit_card.decorator):

```ruby
module Workarea
  decorate Payment::Capture::CreditCard, with: :braintree do
    def complete!
      validate_reference!

      transaction.response = handle_active_merchant_errors do
        gateway.capture(
          transaction.amount.cents,
          transaction.reference.response.authorization
        )
      end
    end
  end
end
```


### Refund

TODO: section introduction


#### Base Implementation

The refund operation implementation for the credit card tender type is already implemented in base.

[`Payment::Refund::CreditCard` from Workarea Core 3.4.20](https://github.com/workarea-commerce/workarea/blob/v3.4.20/core/app/models/workarea/payment/refund/credit_card.rb):

```ruby
module Workarea
  class Payment
    class Refund
      class CreditCard
        include OperationImplementation
        include CreditCardOperation

        def complete!
          validate_reference!

          transaction.response = handle_active_merchant_errors do
            gateway.refund(
              transaction.amount.cents,
              transaction.reference.response.authorization
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

You can decorate it to customize it.


#### Decorator Boilerplate

Start with the following boilerplate and customize it as necessary.
Refer to the inline annotations for guidance.

```ruby
# your_engine/app/models/workarea/payment/refund/credit_card.decorator [1]

module Workarea
  decorate Payment::Refund::CreditCard, with: :your_engine do #[1][2]
    def complete! #[5]
      validate_reference! #[19]

      transaction.response = #[7][8]
        handle_active_merchant_errors do #[9]
          gateway.refund( #[23]
            transaction.amount.cents, #[21]
            transaction.reference.response.authorization
          )
        end
    end

    # def cancel! #[24]
    # end
  end
end
```

__[23]__
Use the appropriate API call for your gateway, which is represented by `gateway` (see section [Gateways](#gateways_1)).
The correct API call is often `refund`, but refer to your gateway's documentation.

__[24]__
For a credit card refund, there is nothing to cancel, so this is implemented as a noop in the base implementation.
However, if your gateway provides an appropriate API call, use it here instead.


#### Decorator Example

Here is a concrete example of a refund operation implementation decorator used in production.

[`Payment::Refund::CreditCard` decorator from Workarea Braintree 1.0.3](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/app/models/workarea/payment/refund/credit_card.decorator):

```ruby
module Workarea
  decorate Payment::Refund::CreditCard, with: :braintree do
    def complete!
      validate_reference!

      transaction.response = handle_active_merchant_errors do
        gateway.refund(
          transaction.amount.cents,
          transaction.reference.response.authorization
        )
      end
    end
  end
end
```


Storefront Integration
----------------------------------------------------------------------

TODO: section

Credit card icons config/validation.

Storefront integration test.
