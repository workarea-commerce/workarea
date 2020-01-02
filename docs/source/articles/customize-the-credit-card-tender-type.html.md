---
title: Customize the Credit Card Tender Type
excerpt: How to customize the credit card tender type, including gateway, proxy, tokenization, operation implementations, and Storefront integration
created_at: 2019/12/03
---

Customize the Credit Card Tender Type
======================================================================

Workarea provides a credit card tender type, but it is not integrated with a payment processing service.
Therefore, application developers must customize the credit card tender type to meet the needs of the retailer.

Workarea provides many plugins that do this work for you for various payment processors.
You should use one of these plugins if you can.
However, there are many payment services (for examples, see the list of [gateways included in Active Merchant 1.102.0](https://github.com/activemerchant/active_merchant/tree/v1.102.0/lib/active_merchant/billing/gateways)).
A retailer may choose a service for which a Workarea plugin does not yet exist.

In that case, you will need to extend the credit card tender type yourself, either directly within an application or within a plugin that can be re-used across applications.
This document provides the procedure to do this work, which can be summarized as:

1. Set up the [credit card gateway](#credit-card-gateway) to communicate (or simulate communication with) the payment service
2. Edit the [proxy configuration](#proxy-configuration) to allow communication with the payment service (Commerce Cloud only)
3. Customize [credit card tokenization](#credit-card-tokenization) for your gateway
4. Customize the credit card [operation implementations](#operation-implementations) for your gateway
5. Customize the [Storefront integration](#storefront-integration) as desired by the retailer


Credit Card Gateway
----------------------------------------------------------------------

Workarea communicates with the credit card processing service through a gateway object.
Workarea initializes a credit card gateway for you, but it uses a bogus gateway that does not communicate with an actual payment service.
(The specific gateway class is [`ActiveMerchant::Billing::BogusGateway` from Active Merchant 1.102.0](https://www.rubydoc.info/gems/activemerchant/1.102.0/ActiveMerchant/Billing/BogusGateway).)

Within your application or plugin, you must replace the default gateway.
The following sections explain how to do this, first for automated testing, and then for production and development environments.


### Automated Testing

Workarea provides automated tests that are intended to communicate with an actual payment service, to test its integration with Workarea.
However, to avoid coupling tests to a network service, you should use [vcr](https://rubygems.org/gems/vcr) cassettes to record the payment service's responses and commit those cassettes to your repository.

To use this pattern, create a module that sets up the gateway to be used with vcr, and then mix that module into specific tests.
The following sections provide boilerplate for your test support module and test decorators, followed by concrete examples from a production implementation.


#### Credit Card vcr Gateway Mixin

Start with the following boilerplate to create a module that changes the credit card gateway for the duration of a test.
You will mix this module into test cases that should use the vcr gateway rather than the original credit card gateway.
Refer to the annotations to customize the boilerplate for your specific implementation.

```ruby
# your_engine/test/support/workarea/credit_card_vcr_gateway.rb [1][2]

module Workarea
  module CreditCardVcrGateway #[3]
    def self.included(test)
      test.setup :set_up_gateway
      test.teardown :reset_gateway
    end

    def set_up_gateway
      @_old_gateway = Workarea.config.gateways.credit_card
      Workarea.config.gateways.credit_card = #[4]
        ActiveMerchant::Billing::CreditCardGateway.new( #[5]
          merchant_id: 'foo', #[6]
          private_key: 'bar',
          baz: 'qux'
        )
    end

    def reset_gateway
      Workarea.config.gateways.credit_card = @_old_gateway #[7]
    end
  end
end
```

__[1]__
Replace the pathname `your_engine` with the pathname for your application or plugin, such as `~/discount-supercenter` or `~/workarea-processor-pro`.

__[2]__
Replace the filename `credit_card_vcr_gateway.rb` with one specific to your gateway, such as `processor_pro_vcr_gateway.rb`.

__[3]__
Rename this module to be specific to your gateway, such as `ProcessorProVcrGateway`.

__[4]__
In the setup method, re-assign the gateway instance stored in `Workarea.config.gateways.credit_card`.
The gateway you assign here will be used as the credit card gateway for all test cases that mix in this module.

__[5]__
Initialize the gateway object you want to use for automated testing with vcr.
Typically, this object is of the same class as your production gateway, but the initialization arguments may differ from production.
Work with your retailer and/or other partners to determine the correct gateway class and arguments.

__[6]__
Initially, use actual credentials (via
[Rails secrets](https://api.rubyonrails.org/v5.2/classes/Rails/Application.html#method-i-secrets) or
[Rails credentials](https://api.rubyonrails.org/v5.2/classes/Rails/Application.html#method-i-credentials))
so you can communicate with the payment service over the network and record the vcr cassettes.
After the cassettes are recorded, remove all credentials (or use dummy values if the arguments are required).
The credentials are no longer needed since the responses will be read from the cassettes.
__Don't commit secrets to your repository!__

__[7]__
In the teardown method, restore the original credit card gateway.


#### Integration Test Decorator

Workarea Core provides [`Payment::CreditCardIntegrationTest`](https://github.com/workarea-commerce/workarea/blob/v3.5.0/core/test/models/workarea/payment/credit_card_integration_test.rb) to test the integration of Workarea and the payment processing service.

Decorate this test to include the module you created above.
When your credit card tender type implementation is complete, the tests in this test case should continue to pass without modifying them.

Start with the following boilerplate, customizing as indicated by the annotations.

```ruby
# your_engine/test/models/workarea/payment/credit_card_integration_test.decorator [1]

module Workarea
  decorate Payment::CreditCardIntegrationTest, with: :your_engine do #[8]
    decorated { include CreditCardVcrGateway } #[9]
  end
end
```

__[8]__
If developing an application, you can omit the `with` argument.
If developing a plugin, replace `your_engine` with a slug identifying your plugin, such as `processor_pro`.

__[9]__
Include the module that sets up your vcr gateway.
See __[3]__.


#### Operation Implementation Test Decorators

The other tests that should use your vcr gateway are the operation implementation model tests (see section [Operation Implementations](#operation-implementations)).
Decorate each of those test cases to mix in the vcr gateway module, and then modify or add tests to cover your specific gateway.
At a minimum, you'll likely need to modify some existing tests to use new cassettes that are specific to your gateway.
Start with the following boilerplate, and refer to the inline annotations and the concrete examples further below.

```ruby
# your_engine/test/models/workarea/payment/authorize/credit_card_test.decorator [1]

module Workarea
  decorate Payment::Authorize::CreditCardTest, with: :your_engine do #[8]
    decorated { include CreditCardVcrGateway } #[9]

    # [10]
    #
    # def test_foo
    #   VCR.use_cassette 'credit_card_gateway/foo' do
    #     super
    #   end
    # end
    #
    # ...
  end
end
```

```ruby
# your_engine/test/models/workarea/payment/purchase/credit_card_test.decorator [1]

module Workarea
  decorate Payment::Purchase::CreditCardTest, with: :your_engine do #[8]
    decorated { include CreditCardVcrGateway } #[9]

    # [10]
    #
    # def test_foo
    #   VCR.use_cassette 'credit_card_gateway/foo' do
    #     super
    #   end
    # end
    #
    # ...
  end
end
```

```ruby
# your_engine/test/models/workarea/payment/capture/credit_card_test.decorator [1]

module Workarea
  decorate Payment::Capture::CreditCardTest, with: :your_engine do #[8]
    decorated { include CreditCardVcrGateway } #[9]

    # [10]
    #
    # def test_foo
    #   VCR.use_cassette 'credit_card_gateway/foo' do
    #     super
    #   end
    # end
    #
    # ...
  end
end
```

```ruby
# your_engine/test/models/workarea/payment/refund/credit_card_test.decorator [1]

module Workarea
  decorate Payment::Refund::CreditCardTest, with: :your_engine do #[8]
    decorated { include CreditCardVcrGateway } #[9]

    # [10]
    #
    # def test_foo
    #   VCR.use_cassette 'credit_card_gateway/foo' do
    #     super
    #   end
    # end
    #
    # ...
  end
end
```

__[10]__
Decorate each test in this test case to use a vcr cassette, and/or add more tests specific to your gateway that use vcr cassettes.
Refer to the concrete examples in the next section.

(
The full set of changes to these tests goes beyond gateway setup and gets into operation implementations, which are covered separately.
See section [Operation Implementations](#operation-implementations).
)


#### Automated Testing Gateway Examples

In addition to the boilerplate above, refer to the following concrete examples from the [Workarea Braintree 1.0.3 source](https://github.com/workarea-commerce/workarea-braintree/tree/v1.0.3):

* Credit card vcr gateway mixin:
  [`BraintreeGatewayVCRConfig`](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/test/support/workarea/braintree_support_vcr_config.rb)
* Integration test decorator:
  [`Payment::CreditCardIntegrationTest`](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/test/models/workarea/payment/credit_card_integration_test.decorator)
* Integration test vcr cassettes:
  [`/test/vcr_cassettes/credit_card/`](https://github.com/workarea-commerce/workarea-braintree/tree/v1.0.3/test/vcr_cassettes/credit_card)
* Operation implementation test decorators:
  * [`Payment::Authorize::CreditCardTest`](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/test/models/workarea/payment/authorize/credit_card_test.decorator)
  * [`Payment::Purchase::CreditCardTest`](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/test/models/workarea/payment/purchase/credit_card_test.decorator)
  * [`Payment::Capture::CreditCardTest`](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/test/models/workarea/payment/capture/credit_card_test.decorator)
  * [`Payment::Refund::CreditCardTest`](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/test/models/workarea/payment/refund/credit_card_test.decorator)
* Operation implementation test vcr cassettes:
  [`/test/vcr_cassettes/braintree`](https://github.com/workarea-commerce/workarea-braintree/tree/v1.0.3/test/vcr_cassettes/braintree)


### Production & Development

Workarea initializes a default credit card gateway and assigns it to `Workarea.config.gateways.credit_card` (in the [`11_payment.rb` initializer](https://github.com/workarea-commerce/workarea/blob/v3.5.0/core/config/initializers/11_payment.rb#L10)).
For use cases other than automated testing, change the credit card gateway by creating your own initializer where you can initialize and re-assign an appropriate credit card gateway for each use case.

The following sections provide boilerplate for an initializer and a concrete example.


#### Gateway Initializer Boilerplate

Start with the following boilerplate to initialize your credit card gateway.
Refer to the inline annotations and customize as needed.

```ruby
# your_engine/config/initializers/credit_card_gateway.rb [1][2]

credentials = Rails.application.secrets.credit_card_gateway #[2][3]

if credentials.present? #[4]
  Workarea.config.gateways.credit_card = #[5]
    ActiveMerchant::Billing::CreditCardGateway.new( #[6]
      credentials.deep_symbolize_keys
    )
else
  Workarea.config.gateways.credit_card = #[5]
    ActiveMerchant::Billing::BogusCreditCardGateway.new #[6]
end
```

__[1]__
Replace the pathname `your_engine` with the pathname for your application or plugin, such as `~/discount-supercenter` or `~/workarea-processor-pro`.

__[2]__
Replace the substring `credit_card_gateway` with one specific to your gateway, such as `processor_pro`.

__[3]__
Optionally replace [Rails secrets](https://api.rubyonrails.org/v5.2/classes/Rails/Application.html#method-i-secrets)
with [Rails credentials](https://api.rubyonrails.org/v5.2/classes/Rails/Application.html#method-i-credentials),
or another solution that keeps your credentials out of your source code repository.

__[4]__
Replace the logic here with your own use cases.
You may want to vary your gateway initialization logic based on credentials, rails environment, current site (if multi site), or other application states or combination of states.

__[5]__
Within each logical branch, ensure you assign an initialized gateway object to `Workarea.config.gateways.credit_card`.

__[6]__
Within each logical branch, replace the class and initialization arguments with the gateway class and arguments appropriate to your payment service and use case.
Work with your retailer and/or other partners to determine the correct gateway classes, arguments, and credentials.


#### Gateway Initializer Example

For a concrete example, refer to the [`workarea.rb` initializer from Workarea Braintree 1.0.3](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/config/initializers/workarea.rb#L1), which delegates much of the logic to [`Workarea::Braintree.auto_configure_gateway`](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/lib/workarea/braintree.rb#L8-L24).

( You can use this pattern yourself if creating a plugin, but it's overkill for an implementation directly within an application. )

With Workarea Braintree 1.0.3 installed, calling `Workarea.config.gateways.credit_card` returns an instance of either:

[`ActiveMerchant::Billing::BraintreeGateway` from Active Merchant 1.102.0](https://www.rubydoc.info/gems/activemerchant/1.102.0/ActiveMerchant/Billing/BraintreeGateway), or

[`ActiveMerchant::Billing::BogusBraintreeGateway` from Workarea Braintree 1.0.3](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/lib/active_merchant/billing/bogus_braintree_gateway.rb).


Proxy Configuration
----------------------------------------------------------------------

( The following step applies to __Workarea Commerce Cloud only__. )

With your gateway set up, you must allow Workarea to communicate with the payment service over the network.
To do so, add the endpoint(s) for the payment service to the proxy configuration using the Workarea CLI.

See [CLI, Edit](/cli.html#edit).


Credit Card Tokenization
----------------------------------------------------------------------

Your credit card gateway must support tokenization.
Workarea persists credit cards during payment transactions (see section [Operation Implementations](#operation-implementations)), and also when shoppers manage cards in their accounts in the Storefront.
Before persisting a card, it must be tokenized.

Workarea encapsulates its tokenization logic in the class [`Payment::StoreCreditCard`](https://github.com/workarea-commerce/workarea/blob/v3.5.0/core/app/models/workarea/payment/store_credit_card.rb).
You may need to decorate this class to customize it for your gateway.
The following sections provide boilerplate for this decorator and a concrete example.


#### Tokenization Decorator Boilerplate

```ruby
# your_engine/app/models/workarea/payment/store_credit_card.decorator [1]

module Workarea
  decorate Payment::StoreCreditCard, with: :your_engine do #[2]
    def perform! #[3]
      return true if @credit_card.token.present?

      response = handle_active_merchant_errors do #[4]
        gateway.store(@credit_card.to_active_merchant) #[5]
      end

      @credit_card.token = response.params['billingid'] #[6]

      response.success?
    end
  end
end
```

__[1]__
Replace the pathname `your_engine` with the pathname for your application or plugin, such as `~/discount-supercenter` or `~/workarea-processor-pro`.

__[2]__
If developing an application, you can omit the `with` argument.
If developing a plugin, replace `your_engine` with a slug identifying your plugin, such as `processor_pro`.

__[3]__
Re-implement `perform!` with the appropriate changes for your gateway.
The method `gateway` returns the gateway object described in the section [Credit Card Gateway](#credit-card-gateway).

__[4]__
You should handle gateway exceptions.
For an Active Merchant gateway, you can re-use `handle_active_merchant_errors` from the base implementation.
If you are not using an Active Merchant gateway, consider implementing your own error handling here.

__[5]__
Use the appropriate API call to store a credit card for your gateway, and pass the appropriate arguments.
The correct API call is often `store`.
Refer to your gateway's documentation for the method name and expected arguments.

__[6]__
If your gateway returns the token in a different param, update that here.
Check your gateway's documentation.


#### Tokenization Decorator Example

For a concrete example, refer to the [`Payment::StoreCreditCard` decorator from Workarea Braintree 1.0.3](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/app/models/workarea/payment/store_credit_card.decorator).


Operation Implementations
----------------------------------------------------------------------

Workarea uses operation implementations to create _authorize_, _purchase_, _capture_, and _refund_ transactions.
Each operation implementation communicates with the payment service through the gateway and implements `#complete!` and `#cancel!`.
For each implementation operation, you may need to customize one or both of those methods for your gateway.

The following sections look at each operation implementation.


### Authorize

For the _authorize_ operation implementation, decorate [`Payment::Authorize::CreditCard`](https://github.com/workarea-commerce/workarea/blob/v3.5.0/core/app/models/workarea/payment/authorize/credit_card.rb) to customize it for your gateway.
Use the boilerplate and examples that follow for guidance.


#### Authorize Decorator Boilerplate

Start with the following boilerplate and customize it as necessary.

```ruby
# your_engine/app/models/workarea/payment/authorize/credit_card.decorator [1]

module Workarea
  decorate Payment::Authorize::CreditCard, with: :your_engine do #[2]
    def complete! #[3]
      return unless StoreCreditCard.new(tender, options).save! #[4]

      transaction.response = #[5][6]
        handle_active_merchant_errors do #[7]
          gateway.authorize( #[8]
            transaction.amount.cents, #[9]
            tender.to_token_or_active_merchant,
            transaction_options #[10]
          )
        end
    end

    def cancel! #[11]
      return unless transaction.success? #[12]

      transaction.cancellation = #[13][6]
        handle_active_merchant_errors do #[7]
          gateway.void( #[14]
            transaction.response.authorization #[15]
          )
        end
    end

    private

    def transaction_options #[10]
      {
        order_id: tender.payment.id, #[16]
        foo: 'bar',
        baz: 'qux'
      }
    end
  end
end
```

__[1]__
Replace the pathname `your_engine` with the pathname for your application or plugin, such as `~/discount-supercenter` or `~/workarea-processor-pro`.

__[2]__
If developing an application, you can omit the `with` argument.
If developing a plugin, replace `your_engine` with a slug identifying your plugin, such as `processor_pro`.

__[3]__
If necessary for your gateway, re-implement `complete!`, which is part of the operation implementation contract.
Note that you may be able to decorate `transaction_options` instead.
See __[10]__.

__[4]__
You must tokenize the credit card and persist the token for future use.
You can do this in a dedicated request to the gateway using `StoreCreditCard#save` (see section [Credit Card Tokenization](#credit-card-tokenization)).
Or, if supported by your gateway, you can tokenize in the same request as the authorization.
If you do so, you must save the token after the authorize request succeeds.

Here is boilerplate for that scenario:

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

__[5]__
You must assign `transaction.response` to fulfill the contract for `#complete!`.

__[6]__
The value assigned must be an object of type [`ActiveMerchant::Billing::Response`](https://www.rubydoc.info/gems/activemerchant/1.102.0/ActiveMerchant/Billing/Response), which is returned by Active Merchant gateways.
If your gateway doesn't return this type of object, you'll have to initialize the instance yourself, constructing the arguments from the gateway's response.

__[7]__
You should handle gateway exceptions.
For an Active Merchant gateway, you can re-use `handle_active_merchant_errors` from the base implementation.
If you are not using an Active Merchant gateway, consider implementing your own error handling here.

__[8]__
Use the appropriate API call for your gateway, which is represented by `gateway` (see section [Credit Card Gateway](#credit-card-gateway)).
The correct API call is often `authorize`, but refer to your gateway's documentation.

__[9]__
Pass the proper arguments for the gateway API call.
The first argument is typically the amount in cents.
To construct this data, you have access to `transaction`, `tender`, `options`, and `address`.

__[10]__
Implement `transaction_options` to return a hash containing the data required by your gateway.
You may be able to decorate only this method if your gateway uses the same tokenization logic and API calls as the base implementation.

__[11]__
If necessary for your gateway, re-implement `cancel!`, which is part of the operation implementation contract.

__[12]__
You must return early if the transaction wasn't successful to fulfill the contract for `#cancel!`.

__[13]__
You must assign `transaction.cancellation` to fulfill the contract for `#cancel!`.

__[14]__
Use the appropriate API call for your gateway, which is represented by `gateway` (see section [Credit Card Gateway](#credit-card-gateway)).
The correct API call is often `void` or `cancel`, but refer to your gateway's documentation.

__[15]__
Pass the proper arguments for the gateway API call.
The first argument is typically a reference to the original authorization.
To construct this data, you have access to `transaction`, `tender`, `options`, and `address`.

__[16]__
To construct the transaction options data, you have access to `transaction`, `tender`, `options`, and `address`.


#### Authorize Decorator Example

Here is a concrete example of an _authorize_ operation implementation decorator used in production:

[`Payment::Authorize::CreditCard` decorator from Workarea Braintree 1.0.3](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/app/models/workarea/payment/authorize/credit_card.decorator)


### Purchase

For the _purchase_ operation implementation, decorate [`Payment::Purchase::CreditCard`](https://github.com/workarea-commerce/workarea/blob/v3.5.0/core/app/models/workarea/payment/purchase/credit_card.rb) to customize it for your gateway.
Use the boilerplate and examples that follow for guidance.


#### Purchase Decorator Boilerplate

Start with the following boilerplate and customize it as necessary.

```ruby
# your_engine/app/models/workarea/payment/purchase/credit_card.decorator [1]

module Workarea
  decorate Payment::Purchase::CreditCard, with: :your_engine do #[1][2]
    def complete! #[3]
      return unless StoreCreditCard.new(tender, options).save! #[4]

      transaction.response = #[5][6]
        handle_active_merchant_errors do #[7]
          gateway.purchase( #[17]
            transaction.amount.cents, #[9]
            tender.to_token_or_active_merchant,
            transaction_options #[10]
          )
        end
    end

    def cancel! #[11]
      return unless transaction.success? #[12]

      transaction.cancellation = #[13][6]
        handle_active_merchant_errors do #[7]
          gateway.void( #[14]
            transaction.response.authorization #[15]
          )
        end
    end

    private

    def transaction_options #[10]
      {
        order_id: tender.payment.id, #[16]
        foo: 'bar',
        baz: 'qux'
      }
    end
  end
end
```

__[17]__
Use the appropriate API call for your gateway, which is represented by `gateway` (see section [Credit Card Gateway](#credit-card-gateway)).
The correct API call is often `purchase`, but refer to your gateway's documentation.


#### Purchase Decorator Example

Here is a concrete example of a _purchase_ operation implementation decorator used in production.

[`Payment::Purchase::CreditCard` decorator from Workarea Braintree 1.0.3](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/app/models/workarea/payment/purchase/credit_card.decorator)


### Capture

For the _capture_ operation implementation, decorate [`Payment::Capture::CreditCard`](https://github.com/workarea-commerce/workarea/blob/v3.5.0/core/app/models/workarea/payment/capture/credit_card.rb) to customize it for your gateway.
Use the boilerplate and examples that follow for guidance.


#### Capture Decorator Boilerplate

Start with the following boilerplate and customize it as necessary.

```ruby
# your_engine/app/models/workarea/payment/capture/credit_card.decorator [1]

module Workarea
  decorate Payment::Capture::CreditCard, with: :your_engine do #[1][2]
    def complete! #[3]
      validate_reference! #[18]

      transaction.response = #[5][6]
        handle_active_merchant_errors do #[7]
          gateway.capture( #[19]
            transaction.amount.cents, #[20]
            transaction.reference.response.authorization
          )
        end
    end

    # def cancel! #[21]
    # end
  end
end
```

__[18]__
You must use `validate_reference!` for a capture operation, unless this does not apply to your gateway.

__[19]__
Use the appropriate API call for your gateway, which is represented by `gateway` (see section [Credit Card Gateway](#credit-card-gateway)).
The correct API call is often `capture`, but refer to your gateway's documentation.

__[20]__
Pass the proper arguments for the gateway API call.
The first argument is typically the amount in cents.
The second argument is typically a reference to the original transaction's authorization.
To construct this data, you have access to `transaction`, `tender`, `options`, and `address`.

__[21]__
For a credit card capture, there isn't anything to cancel, so this is implemented in the base implementation to do nothing.
However, if your gateway provides an appropriate API call, use it here instead.


#### Refund Decorator Example

Here is a concrete example of a _capture_ operation implementation decorator used in production:

[`Payment::Capture::CreditCard` decorator from Workarea Braintree 1.0.3](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/app/models/workarea/payment/capture/credit_card.decorator)


### Refund

For the _refund_ operation implementation, decorate [`Payment::Refund::CreditCard`](https://github.com/workarea-commerce/workarea/blob/v3.5.0/core/app/models/workarea/payment/refund/credit_card.rb) to customize it for your gateway.
Use the boilerplate and examples that follow for guidance.


#### Refund Decorator Boilerplate

Start with the following boilerplate and customize it as necessary.

```ruby
# your_engine/app/models/workarea/payment/refund/credit_card.decorator [1]

module Workarea
  decorate Payment::Refund::CreditCard, with: :your_engine do #[1][2]
    def complete! #[3]
      validate_reference! #[18]

      transaction.response = #[5][6]
        handle_active_merchant_errors do #[7]
          gateway.refund( #[22]
            transaction.amount.cents, #[20]
            transaction.reference.response.authorization
          )
        end
    end

    # def cancel! #[23]
    # end
  end
end
```

__[22]__
Use the appropriate API call for your gateway, which is represented by `gateway` (see section [Credit Card Gateway](#credit-card-gateway)).
The correct API call is often `refund`, but refer to your gateway's documentation.

__[23]__
For a credit card refund, there is nothing to cancel, so this is implemented as a noop in the base implementation.
However, if your gateway provides an appropriate API call, use it here instead.
Use `validate_reference!` if the API call requires a reference transaction.


#### Decorator Example

Here is a concrete example of a _refund_ operation implementation decorator used in production:

[`Payment::Refund::CreditCard` decorator from Workarea Braintree 1.0.3](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/app/models/workarea/payment/refund/credit_card.decorator)


Storefront Integration
----------------------------------------------------------------------

The credit card tender type is already fully integrated into the Workarea Storefront.
However, the base implementation provides a configuration for credit card issuers that you may want to modify.

Modify [`Workarea.config.credit_card_issuers`](https://github.com/workarea-commerce/workarea/blob/v3.5.0/core/lib/workarea/configuration.rb#L129-L139) to change which credit card issuer icons are displayed in the checkout UI.

Since Workarea 3.5, this config is also used by the validation [`Payment::CreditCard#issuer_accepted`](https://github.com/workarea-commerce/workarea/blob/v3.5.0/core/app/models/workarea/payment/credit_card.rb#L89-L98), which determines the credit card issuers that are accepted.

( See [Configuration](/articles/configuration.html) for coverage of Workarea configuration. )
