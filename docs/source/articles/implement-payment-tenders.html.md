---
title: Implement Payment Tenders
excerpt: A general procedure to implement credit card payments and other tender types, including examples
created_at: 2019/10/10
---

Implement Payment Tenders
======================================================================

Example tender types:

* _Store credit_ and _credit card_ (partial implementation) from _Workarea_ v3.5.0 (
  [gem](https://rubygems.org/gems/workarea/versions/3.5.0),
  [docs](https://developer.workarea.com/),
  [source](https://github.com/workarea-commerce/workarea/tree/v3.5.0)
  )
* _Credit card_ (extensions to base) from _Workarea Braintree_ v1.0.3 (
  [gem](https://rubygems.org/gems/workarea-braintree/versions/1.0.3),
  [docs](https://www.rubydoc.info/gems/workarea-braintree/1.0.3),
  [source](https://github.com/workarea-commerce/workarea-braintree/tree/v1.0.3)
  )
* _Gift card_ from _Workarea Gift Cards_ v3.5.0 (
  [gem](https://rubygems.org/gems/workarea-gift_cards/versions/3.5.0),
  [docs](https://www.rubydoc.info/gems/workarea-gift_cards/3.5.0),
  [source](https://github.com/workarea-commerce/workarea-gift-cards/tree/v3.5.0)
  )
* _PayPal_ from _Workarea PayPal_ v2.0.8 (
  [gem](https://rubygems.org/gems/workarea-paypal/versions/2.0.8),
  [docs](https://www.rubydoc.info/gems/workarea-paypal/2.0.8),
  [source](https://github.com/workarea-commerce/workarea-paypal/tree/v2.0.8)
  )


Tender Type
----------------------------------------------------------------------

[`Payment::Tender`](https://github.com/workarea-commerce/workarea/blob/master/core/app/models/workarea/payment/tender.rb)

* [`Payment::Tender::CreditCard`](https://github.com/workarea-commerce/workarea/blob/master/core/app/models/workarea/payment/tender/credit_card.rb)
* [`Payment::Tender::Paypal`](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/models/workarea/payment/tender/paypal.rb)
* [`Payment::Tender::StoreCredit`](https://github.com/workarea-commerce/workarea/blob/master/core/app/models/workarea/payment/tender/store_credit.rb)
* [`Payment::Tender::GiftCard`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/models/workarea/payment/tender/gift_card.rb)


Payment
----------------------------------------------------------------------

[`Payment`](https://github.com/workarea-commerce/workarea/blob/master/core/app/models/workarea/payment.rb)

* [Workarea PayPal](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/models/workarea/payment.decorator)
* [Workarea Gift Cards](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/models/workarea/payment.decorator)


Tender Types Configuration
----------------------------------------------------------------------

[Default configuration](https://github.com/workarea-commerce/workarea/blob/master/core/lib/workarea/configuration.rb#L77-L79)

* [Workarea PayPal](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/config/initializers/workarea.rb#L1)
* [Workarea Gift Cards](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/config/initializers/configuration.rb#L6)


Gateways
----------------------------------------------------------------------

[`ActiveMerchant::Billing::Gateway`](https://www.rubydoc.info/gems/activemerchant/1.99.0/ActiveMerchant/Billing/Gateway)

Credit card gateway (Workarea Core):

* [Workarea Core configuration](https://github.com/workarea-commerce/workarea/blob/master/core/config/initializers/11_payment.rb)
* [`ActiveMerchant::Billing::BogusGateway`](https://www.rubydoc.info/gems/activemerchant/1.99.0/ActiveMerchant/Billing/BogusGateway)

Credit card gateway (Workarea Braintree):

* [Workarea Braintree configuration](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/lib/workarea/braintree.rb#L8-L24)
* [`ActiveMerchant::Billing::BraintreeGateway`](https://www.rubydoc.info/gems/activemerchant/1.99.0/ActiveMerchant/Billing/BraintreeGateway)
* [`ActiveMerchant::Billing::BogusBraintreeGateway`](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/lib/active_merchant/billing/bogus_braintree_gateway.rb)

PayPal gateway:

* [Workarea PayPal configuration 1 of 2](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/config/initializers/workarea.rb#L7)
* [Workarea PayPal configuration 2 of 2](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/lib/workarea/paypal.rb#L15-L29)
* [`ActiveMerchant::Billing::PaypalExpressGateway`](https://www.rubydoc.info/gems/activemerchant/1.99.0/ActiveMerchant/Billing/BraintreeGateway)
* [`ActiveMerchant::Billing::BogusGateway`](https://www.rubydoc.info/gems/activemerchant/1.99.0/ActiveMerchant/Billing/BogusGateway)

Gift card gateway:

* [Workarea Gift Cards gateway configuration](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/config/initializers/configuration.rb#L10)
* [`Workarea::GiftCards::Gateway`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/lib/workarea/gift_cards/gateway.rb)

Store credit "gateway":

* [`Workarea::Payment::Profile#purchase_on_store_credit`](https://github.com/workarea-commerce/workarea/blob/master/core/app/models/workarea/payment/profile.rb#L41-L48)
* [`Workarea::Payment::Profile#reload_store_credit`](https://github.com/workarea-commerce/workarea/blob/master/core/app/models/workarea/payment/profile.rb#L50-L56)


Proxy (Commerce Cloud)
----------------------------------------------------------------------

Workarea Commerce Cloud uses a proxy to limit outgoing network requests.
If the tender type requires communication with another service over the network, you'll need to add the endpoint(s) to the proxy configuration.

Edit the proxy configuration using the _edit_ command from the [Workarea CLI](/cli.html).
See [Workarea CLI Cheat Sheet, Edit](/cli.html#edit).


Credit Card Tokenization
----------------------------------------------------------------------

Workarea Core:

* [`Payment::StoreCreditCard`](https://github.com/workarea-commerce/workarea/blob/v3.4.14/core/app/models/workarea/payment/store_credit_card.rb)
* [`Payment::StoreCreditCardTest`](https://github.com/workarea-commerce/workarea/blob/v3.4.14/core/test/models/workarea/payment/store_credit_card_test.rb)

Workarea Braintree:

* [`Payment::StoreCreditCard`](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/app/models/workarea/payment/store_credit_card.decorator)
* [`Payment::StoreCreditCardTest`](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/test/models/workarea/payment/store_credit_card_test.decorator)


Operation Implementations
----------------------------------------------------------------------

* [`Payment::OperationImplementation`](https://github.com/workarea-commerce/workarea/blob/v3.4.14/core/app/models/workarea/payment/operation_implementation.rb)

Credit card (Workarea Core):

* [`Payment::CreditCardOperation`](https://github.com/workarea-commerce/workarea/blob/v3.4.14/core/app/models/workarea/payment/credit_card_operation.rb)
* [`Payment::Authorize::CreditCard`](https://github.com/workarea-commerce/workarea/blob/v3.4.14/core/app/models/workarea/payment/authorize/credit_card.rb)
* [`Payment::Purchase::CreditCard`](https://github.com/workarea-commerce/workarea/blob/v3.4.14/core/app/models/workarea/payment/purchase/credit_card.rb)
* [`Payment::Capture::CreditCard`](https://github.com/workarea-commerce/workarea/blob/v3.4.14/core/app/models/workarea/payment/capture/credit_card.rb)
* [`Payment::Refund::CreditCard`](https://github.com/workarea-commerce/workarea/blob/v3.4.14/core/app/models/workarea/payment/refund/credit_card.rb)

Credit card (Workarea Braintree):

* [`Payment::Authorize::CreditCard`](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/app/models/workarea/payment/authorize/credit_card.decorator)
* [`Payment::Purchase::CreditCard`](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/app/models/workarea/payment/purchase/credit_card.decorator)
* [`Payment::Capture::CreditCard`](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/app/models/workarea/payment/capture/credit_card.decorator)
* [`Payment::Refund::CreditCard`](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/app/models/workarea/payment/refund/credit_card.decorator)

PayPal:

* [`Payment::CreditCardOperation`](https://github.com/workarea-commerce/workarea/blob/v3.4.14/core/app/models/workarea/payment/credit_card_operation.rb)
* [`Payment::Authorize::Paypal`](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/models/workarea/payment/authorize/paypal.rb)
* [`Payment::Capture::Paypal`](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/models/workarea/payment/capture/paypal.rb)
* [`Payment::Purchase::Paypal`](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/models/workarea/payment/purchase/paypal.rb)
* [`Payment::Refund::Paypal`](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/models/workarea/payment/refund/paypal.rb)

Store credit:

* [`Payment::Authorize::StoreCredit`](https://github.com/workarea-commerce/workarea/blob/v3.4.14/core/app/models/workarea/payment/authorize/store_credit.rb)
* [`Payment::Purchase::StoreCredit`](https://github.com/workarea-commerce/workarea/blob/v3.4.14/core/app/models/workarea/payment/purchase/store_credit.rb)
* [`Payment::Capture::StoreCredit`](https://github.com/workarea-commerce/workarea/blob/v3.4.14/core/app/models/workarea/payment/capture/store_credit.rb)
* [`Payment::Refund::StoreCredit`](https://github.com/workarea-commerce/workarea/blob/v3.4.14/core/app/models/workarea/payment/refund/store_credit.rb)

Gift card:

* [`Payment::Authorize::GiftCard`](https://github.com/workarea-commerce/workarea-gift-cards/blob/v3.4.6/app/models/workarea/payment/authorize/gift_card.rb)
* [`Payment::Purchase::GiftCard`](https://github.com/workarea-commerce/workarea-gift-cards/blob/v3.4.6/app/models/workarea/payment/purchase/gift_card.rb)
* [`Payment::Capture::GiftCard`](https://github.com/workarea-commerce/workarea-gift-cards/blob/v3.4.6/app/models/workarea/payment/capture/gift_card.rb)
* [`Payment::Refund::GiftCard`](https://github.com/workarea-commerce/workarea-gift-cards/blob/v3.4.6/app/models/workarea/payment/refund/gift_card.rb)


Storefront
----------------------------------------------------------------------

Although there are a few patterns, the Storefront integrations of my example tender types vary a lot.

It would be a lot easier to focus on a single concrete implementation in each doc.


Tests
----------------------------------------------------------------------

Same for tests.

But here are the tests for Braintree (since I already collected them):

* [`Payment::Authorize::CreditCardTest`](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/test/models/workarea/payment/authorize/credit_card_test.decorator)
* [`Payment::Purchase::CreditCardTest`](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/test/models/workarea/payment/purchase/credit_card_test.decorator)
* [`Payment::Capture::CreditCardTest`](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/test/models/workarea/payment/capture/credit_card_test.decorator)
* [`Payment::Refund::CreditCardTest`](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/test/models/workarea/payment/refund/credit_card_test.decorator)
* [`Payment::CreditCardIntegrationTest`](https://github.com/workarea-commerce/workarea-braintree/blob/master/test/models/workarea/payment/credit_card_integration_test.decorator)
* [`Payment::StoreCreditCardTest`](https://github.com/workarea-commerce/workarea-braintree/blob/master/test/models/workarea/payment/store_credit_card_test.decorator)
* [`BraintreeGatewayVCRConfig`](https://github.com/workarea-commerce/workarea-braintree/blob/master/test/support/workarea/braintree_support_vcr_config.rb)
