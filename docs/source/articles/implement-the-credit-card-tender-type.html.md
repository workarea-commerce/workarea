---
title: Implement the Credit Card Tender Type
excerpt: Procedure to complete the base implementation of the credit card tender type, with examples from Workarea Braintree
created_at: 2019/10/15
---

Implement the Credit Card Tender Type
======================================================================

Workarea provides a credit card tender type, but its implementation is incomplete.
You must fully implement this tender type in order to accept credit card payments in production.
For many payment providers, you can install a Workarea plugin that completes the implementation for you.

However, a retailer may choose a payment service provider for which no Workarea plugin is available, or you may be tasked with writing the plugin for a particular provider.
In either case, you can complete the credit card tender type implementation in the following steps:

1. [Implement and configure credit card gateway(s)](#gateways_1)
2. [Configure proxy (Commerce Cloud only)](#proxy_2)
3. [Add test support](#test-support_3)
4. [Implement credit card tokenization](#tokenization_4)
5. [Implement each credit card payment operation](#operation-implementations_5)

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

Workarea [configures](/articles/configuration.html) the credit card gateway as an instance of
[`ActiveMerchant::Billing::BogusGateway`](https://www.rubydoc.info/gems/activemerchant/1.99.0/ActiveMerchant/Billing/BogusGateway), as shown below
([source](https://github.com/workarea-commerce/workarea/blob/v3.4.18/core/config/initializers/11_payment.rb#L6)):

```ruby
if Workarea.config.gateways.credit_card.blank?
  Workarea.config.gateways.credit_card =
    ActiveMerchant::Billing::BogusGateway.new
end
```

This gateway, which is the default bogus gateway from Active Merchant, is useful for local development and testing.
However, for production use, you must choose or implement a gateway that connects to an actual payment service provider, and you must configure Workarea to use this gateway.
You may also want to change the gateway(s) used in non-production environments.

__Workarea requires credit card gateways to support tokenization.__
( See section [Tokenization](#tokenization_4), below.)

Workarea Braintree, a plugin that integrates Workarea with [Braintree](https://www.braintreepayments.com/), relies on
[`ActiveMerchant::Billing::BraintreeGateway`](https://www.rubydoc.info/gems/activemerchant/1.99.0/ActiveMerchant/Billing/BraintreeGateway),
from Active Merchant, as the production gateway.
The plugin also extends Active Merchant to provide its own bogus gateway, 
[`ActiveMerchant::Billing::BogusBraintreeGateway`](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/lib/active_merchant/billing/bogus_braintree_gateway.rb).

Workarea Braintree provides code to autoconfigure Workarea's credit card gateway.
When Braintree credentials are present, the Braintree gateway is used, otherwise the bogus gateway is used
([source](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/lib/workarea/braintree.rb#L8-L24)):

```ruby
def self.auto_configure_gateway
  if Rails.application.secrets.braintree.present?
    self.gateway =
      ActiveMerchant::Billing::BraintreeGateway.new(
        Rails.application.secrets.braintree.deep_symbolize_keys
      )
  else
    self.gateway =
      ActiveMerchant::Billing::BogusBraintreeGateway.new
  end
end

def self.gateway
  Workarea.config.gateways.credit_card
end

def self.gateway=(gateway)
  Workarea.config.gateways.credit_card = gateway
end
```

The plugin calls this code from an initializer
([source](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/config/initializers/workarea.rb#L1)):

```ruby
Workarea::Braintree.auto_configure_gateway
```

If using a plugin to implement the credit card tender type, refer to the plugin's documentation for setup instructions, such as where to store credentials and configurable values for the gateway.


Proxy
----------------------------------------------------------------------

Customers of Workarea Commerce Cloud must additionally add the endpoint(s) for the payment service provider to the proxy configuration, which will enable outgoing requests to the service.

Edit the proxy configuration using the _edit_ command from the [Workarea CLI](/cli.html).
See [Workarea CLI Cheat Sheet, Edit](/cli.html#edit).


Test Support
----------------------------------------------------------------------

With the gateway and proxy configured, you can now make requests to the payment processor.
Before continuing with your implementation, you should ensure automated tests are using the desired gateway as well.
Furthermore, you should use [vcr](https://github.com/vcr/vcr) to record responses from the payment processing service to improve the speed and reliability of your test suite.

Workarea Braintree provides a module, `BraintreeGatewayVCRConfig`, which temporarily configures the credit card gateway to a "sandbox" instance of the Braintree gateway configured for testing.
The plugin mixes this module into any test cases (via [decoration](/articles/decoration.html)) that need to communicate with the Braintree gateway.

[`BraintreeGatewayVCRConfig`](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/test/support/workarea/braintree_support_vcr_config.rb) implementation:

```ruby
module Workarea
  module BraintreeGatewayVCRConfig
    def self.included(test)
      test.setup :setup_gateway
      test.teardown :reset_gateway
    end

    def setup_gateway
      @_old_gateway = Workarea.config.gateways.credit_card
      Workarea.config.gateways.credit_card =
        ActiveMerchant::Billing::BraintreeGateway.new(
          merchant_account_id: 'a',
          merchant_id:         'b',
          public_key:          'c',
          private_key:         'd',
          environment:         'sandbox'
        )
    end

    def reset_gateway
      Workarea.config.gateways.credit_card = @_old_gateway
    end
  end
end
```

For a usage example, refer to Workarea Braintree's
[decoration of `Payment::CreditCardIntegrationTest`](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/test/models/workarea/payment/credit_card_integration_test.decorator):

```ruby
module Workarea
  decorate Payment::CreditCardIntegrationTest, with: :braintree do
    decorated { include BraintreeGatewayVCRConfig }
  end
end
```

The result of this and other decorations is a [collection of VCR cassettes](https://github.com/workarea-commerce/workarea-braintree/tree/v1.0.3/test/vcr_cassettes) that store the responses from the gateway to be used with each automated test run.


Tokenization
----------------------------------------------------------------------

In addition to processing payments, a credit card gateway is responsible for card tokenization.
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

Finally, to finish implementing the credit card tender type, you must implement each credit card operation: authorize, purchase, capture, and refund.
In each case, decorate the class to customize `#complete!`, `#cancel!`, and `#transaction_options` (authorize and purchase only) to account for differences between the default gateway and your chosen gateway.

For the credit card tender type, the authorize and purchase operations must handle tokenization.
There are two general patterns for this behavior.
The first, as demonstrated in the default implementation, is to tokenize the card in a separate request before authorizing the transaction
([source](https://github.com/workarea-commerce/workarea/blob/v3.4.18/core/app/models/workarea/payment/authorize/credit_card.rb)):

```ruby
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
```

The alternative, preferred by Braintree and other gateways, is to tokenize and authorize in the same request, in which case you must save the token after a successful authorization
([source](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/app/models/workarea/payment/authorize/credit_card.decorator)):

```ruby
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
    tender.token =
      transaction.response.params["braintree_transaction"]["credit_card_details"]["token"]
    tender.save!
  end
end
```

Here are all the operation implementations from Workarea Core and Workarea Braintree for reference:

Authorize:

* [Workarea Core implementation](https://github.com/workarea-commerce/workarea/blob/v3.4.18/core/app/models/workarea/payment/authorize/credit_card.rb)
* [Workarea Core test case](https://github.com/workarea-commerce/workarea/blob/v3.4.18/core/test/models/workarea/payment/authorize/credit_card_test.rb)
* [Workarea Braintree implementation extensions](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/app/models/workarea/payment/authorize/credit_card.decorator)
* [Workarea Braintree test case extensions](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/test/models/workarea/payment/authorize/credit_card_test.decorator)

Purchase:

* [Workarea Core implementation](https://github.com/workarea-commerce/workarea/blob/v3.4.18/core/app/models/workarea/payment/purchase/credit_card.rb)
* [Workarea Core test case](https://github.com/workarea-commerce/workarea/blob/v3.4.18/core/test/models/workarea/payment/purchase/credit_card_test.rb)
* [Workarea Braintree implementation extensions](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/app/models/workarea/payment/purchase/credit_card.decorator)
* [Workarea Braintree test case extensions](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/test/models/workarea/payment/purchase/credit_card_test.decorator)

Capture:

* [Workarea Core implementation](https://github.com/workarea-commerce/workarea/blob/v3.4.18/core/app/models/workarea/payment/capture/credit_card.rb)
* [Workarea Core test case](https://github.com/workarea-commerce/workarea/blob/v3.4.18/core/test/models/workarea/payment/capture/credit_card_test.rb)
* [Workarea Braintree implementation extensions](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/app/models/workarea/payment/capture/credit_card.decorator)
* [Workarea Braintree test case extensions](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/test/models/workarea/payment/capture/credit_card_test.decorator)

Refund:

* [Workarea Core implementation](https://github.com/workarea-commerce/workarea/blob/v3.4.18/core/app/models/workarea/payment/refund/credit_card.rb)
* [Workarea Core test case](https://github.com/workarea-commerce/workarea/blob/v3.4.18/core/test/models/workarea/payment/refund/credit_card_test.rb)
* [Workarea Braintree implementation extensions](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/app/models/workarea/payment/refund/credit_card.decorator)
* [Workarea Braintree test case extensions](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/test/models/workarea/payment/refund/credit_card_test.decorator)
