---
title: Implement an Advance Payment Tender Type
excerpt: TODO
created_at: 2019/10/25
---

Implement an Advance Payment Tender Type
======================================================================

[Advance payment tender types](/articles/payment-tender-types.html#advance-payment-tender-types_4) are [payment tender types](/articles/payment-tender-types.html).
Base includes store credit.
But you can also implement your own.

Here is a procedure to do so:

1. [Implement gateways](#gateways_1)
2. [Add tender type definition](#tender-type-definition_2)
3. [Integrate with Payment](#payment-integration_3)
4. [Implement each payment operation](#operation-implementations_4)
5. [Integrate into Storefront](#storefront-integration_5)
6. [Integrate into Admin](#admin-integration_6)

This doc uses examples from _Workarea Gift Cards_ <del>v3.5.0</del> master branch (
[<del>gem</del>](https://rubygems.org/gems/workarea-gift_cards/versions/3.5.0),
[<del>docs</del>](https://www.rubydoc.info/gems/workarea-gift_cards/3.5.0),
[source](https://github.com/workarea-commerce/workarea-gift-cards/tree/master)
).


Gateways
----------------------------------------------------------------------

[Gateways](/articles/implementing-payment-tender-types.html#gateways_1)

See if the service provider or its community provide a Ruby API for the gateway, either directly, or via Active Merchant.
If not, you'll have to implement it on your own.
Generally out of scope for these docs, but you can reference the Gift Cards gateway implementation:

[`GiftCards::Gateway#authorize`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/lib/workarea/gift_cards/gateway.rb#L19-L28)

[`GiftCards::Gateway#purchase`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/lib/workarea/gift_cards/gateway.rb#L53-L74)

[`GiftCards::Gateway#capture`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/lib/workarea/gift_cards/gateway.rb#L41-L51)

[`GiftCards::Gateway#refund`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/lib/workarea/gift_cards/gateway.rb#L76-L95)

Notice how some of the implementation overlaps with the concerns of operation implementations.
e.g. some operations include exception handling, some are aliases for another, some are noops.

Workarea Gift Cards uses a single class of gateway that it provides:
[`GiftCards::Gateway`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/lib/workarea/gift_cards/gateway.rb).
with tests:
[`GiftCards::GatewayTest#gateway`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/test/lib/workarea/gift_cards/gateway_test.rb).

This gateway is entirely local; doesn't talk to a remote service.
The same gateway class is used throughout.
For local development, production, automated tests, etc.

To access the gateway, the plugin implements a module that implements `#gateway`.
[`Payment::GiftCardOperation`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/models/workarea/payment/gift_card_operation.rb).
[`Payment::GiftCardOperation#gateway`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/models/workarea/payment/gift_card_operation.rb#L4-L6).
This module is mixed into objects that need the gateway:
[`Payment::Authorize::GiftCard` including `Payment::GiftCardOperation`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/models/workarea/payment/authorize/gift_card.rb#L6).
The module delegates to:
[`GiftCards.gateway`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/lib/workarea/gift_cards.rb#L7-L9).
Which looks up the name of the gateway in [configuration](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/config/initializers/configuration.rb#L10).

A gateway is initialized every time `#gateway` is called, which is a good pattern to follow.

The gateway is initialized directly for automated tests:
[`GiftCards::GatewayTest#gateway`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/test/lib/workarea/gift_cards/gateway_test.rb#L19-L21).
Using the same pattern: a method that inits the gateway when called.


Operation Implementations
----------------------------------------------------------------------

Introduction to this section.
[Operation Implementations](/articles/implementing-payment-tender-types.html#operation-implementations_8)
Code annotations using running numbers.
In an explain doc, explain the semantics of each operation.


### Authorize


#### Boilerplate

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
Ultimately, you must assign `transaction.response`, see [10].
That value is derived from a response from the gateway, so store the gateway's response for later use.
This example assumes the gateway's response is not already an `ActiveMerchant::Billing::Response`, see [11].

__[7]__
You should handle gateway exceptions.
The module you wrote earlier included `handle_gateway_errors`, which accepts a block.
Wrap that around the code that communicates with the gateway.

__[8]__
Use the right API call for your gateway, but usually authorize.

__[9]__
Pass the proper arguments for the API call.
The first arg is typically the amount in cents.
The args are derived from transaction, tender, and options (the operation implementation is initialized with these).

__[10]__
You must assign `transaction.response`.
This is the primary responsibility of `#complete!`.

__[11]__
The value assigned must be an object of type [`ActiveMerchant::Billing::Response`](https://www.rubydoc.info/gems/activemerchant/1.100.0/ActiveMerchant/Billing/Response).
These examples assume your gateway does not return this type and therefore constructs an instance manually.
However, if your gateway does return this type, you can assign it directly to `transaction.response`, skipping the need to store the gateway response temporarily in `gateway_response`, see [6].

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
You must implement `cancel!`.

__[14]__
You must return early if the transaction wasn't successful (nothing to cancel).

__[15]__
Ultimately, you must assign `transaction.cancellation`, see [18].
That value is derived from a response from the gateway, so store the gateway's response for later use.
This example assumes the gateway's response is not already an `ActiveMerchant::Billing::Response`, see [11].

__[16]__
Use the right API call for your gateway, but usually void, cancel, or refund.

__[17]__
Pass the proper arguments for the API call.
The first arg is typically a reference to the original authorization.
e.g. `transaction.response.authorization` or `transaction.response.params['transaction_id']`
The args are derived from transaction, tender, and options (the operation implementation is initialized with these).

__[18]__
You must assign `transaction.cancellation`.


#### Example

[`Payment::Authorize::GiftCard`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/models/workarea/payment/authorize/gift_card.rb)


### Purchase


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
Use the right API call for your gateway, but usually purchase.
Pass the proper arguments for that API call.
The first arg is typically the amount in cents.
The args are derived from transaction, tender, and options (the operation implementation is initialized with these).


#### Example

[`Payment::Purchase::GiftCard`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/models/workarea/payment/purchase/gift_card.rb)


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
A capture operation often references the original authorization transaction.
If this applies to your gateway, then validate the reference with `validate!_reference`.
This method comes from `Payment::OperationImplementation`.
Omit this API call if your gateway doesn't rely on a reference transaction.

__[21]__
Use the right API call for your gateway, but usually capture.

__[22]__
Pass the proper arguments for the API call.
The first arg is typically the amount in cents.
The second arg is typically something that identifies the reference transaction
e.g. `transaction.reference.response.authorization` or `transaction.reference.response.params['transaction_id']`.
The args are derived from transaction, tender, and options (the operation implementation is initialized with these).

__[23]__
For most gateways, it doesn't make sense to cancel capture, so this method should be implemented to do nothing.
If however, there is an appropriate response for your gateway (e.g. PayPal issues a refund), you should implement it here, using other capture methods for inspiration.


#### Example

[`Payment::Capture::GiftCard`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/models/workarea/payment/capture/gift_card.rb)


### Refund


#### Boilerplate

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
Use the right API call for your gateway, but usually refund.

__[25]__
For most gateways, it doesn't make sense to cancel a refund, so this method should be implemented to do nothing.
If however, there is an appropriate response for your gateway (e.g. Gift Card re-purchases the amount), you should implement it here, using other capture methods for inspiration.


#### Example

[`Payment::Refund::GiftCard`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/models/workarea/payment/refund/gift_card.rb)


Tender Type Definition
----------------------------------------------------------------------

[Tender Type Definition](/articles/implementing-payment-tender-types.html#tender-type-definition_6)

[`Payment::Tender::GiftCard`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/models/workarea/payment/tender/gift_card.rb)

[`Payment::Tender::GiftCard#amount=`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/models/workarea/payment/tender/gift_card.rb#L14-L17)


Payment Integration
----------------------------------------------------------------------

[Payment Integration](/articles/implementing-payment-tender-types.html#payment-integration_7)

[`Payment` decorator](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/models/workarea/payment.decorator)

[tender types configuration](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/config/initializers/configuration.rb#L6)

[`GiftCardPaymentTest`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/test/models/workarea/gift_card_payment_test.rb)


Storefront Integration
----------------------------------------------------------------------

[Storefront Integration](/articles/implementing-payment-tender-types.html#storefront-integration_9)

[Checkout steps configuration](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/config/initializers/configuration.rb#L5)

[Storefront SVG icon](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/assets/images/workarea/storefront/payment_icons/gift_card.svg)

[`Api::Storefront::CheckoutsController` decorator](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/controllers/workarea/api/storefront/checkouts_controller.decorator)

[`Storefront::Checkout::GiftCardsController`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/controllers/workarea/storefront/checkout/gift_cards_controller.rb)

[`Checkout::Steps::GiftCard`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/models/workarea/checkout/steps/gift_card.rb)

[`Storefront::GiftCardOrderPricing`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/view_models/workarea/storefront/gift_card_order_pricing.rb)

[`Storefront::GiftCardOrderPricing` including](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/lib/workarea/gift_cards/engine.rb#L7-L16)

[`Storefront::OrderViewModel` decorator](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/view_models/workarea/storefront/order_view_model.decorator)

[Storefront API checkout steps partial](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/views/workarea/api/storefront/checkouts/steps/_gift_card.json.jbuilder)

[Storefront API order tenders partial](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/views/workarea/api/storefront/orders/tenders/_gift_card.json.jbuilder)

[Storefront checkouts error partial](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/views/workarea/storefront/checkouts/_gift_card_error.html.haml)

[Configuration for Storefront checkouts error partial](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/config/initializers/append_points.rb#L10-L13)

[Storefront checkouts payment partial](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/views/workarea/storefront/checkouts/_gift_card_payment.html.haml)

[Configuration for Storefront checkouts payment partial](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/config/initializers/append_points.rb#L15-L18)

[Storefront checkouts summary partial](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/views/workarea/storefront/checkouts/_gift_card_summary.html.haml)

[Configuration for Storefront checkouts summary partial](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/config/initializers/append_points.rb#L5-L8)

[Storefront order mailer summary partial](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/views/workarea/storefront/order_mailer/_gift_card_summary.html.haml)

[Configuration for Storefront order mailer summary partial](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/config/initializers/append_points.rb#L25-L28)

[Storefront order mailer tenders partial](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/views/workarea/storefront/order_mailer/tenders/_gift_card.html.haml)

[Storefront orders summary partial](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/views/workarea/storefront/orders/_gift_card_summary.html.haml)

[Configuration for Storefront orders summary partial](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/config/initializers/append_points.rb#L20-L23)

[Storefront orders tenders partial](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/views/workarea/storefront/orders/tenders/_gift_card.html.haml)

[Core and Storefront translations](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/config/locales/en.yml#L50-L92)

[Storefront routes](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/config/routes.rb#L9-L19)

[Storefront API routes](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/config/routes.rb#L28-L37)

[`Api::Storefront::GiftCardsDocumentationTest`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/test/documentation/workarea/api/storefront/gift_cards_documentation_test.rb)

[`Api::Storefront::CheckoutGiftCardsIntegrationTest`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/test/integration/workarea/api/storefront/checkout_gift_cards_integration_test.rb)

[`Storefront::CheckoutGiftCardsIntegrationTest`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/test/integration/workarea/storefront/checkout_gift_cards_integration_test.rb)

[`Checkout::Steps::GiftCardTest`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/test/models/workarea/checkout/steps/gift_card_test.rb)

[`Storefront::GiftCardSystemTest`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/test/system/workarea/storefront/gift_cards_system_test.rb)

[`Storefront::GiftCardOrderPricingTest`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/test/view_models/workarea/storefront/gift_card_order_pricing_test.rb)


Admin Integration
----------------------------------------------------------------------

[Admin Integration](/articles/implementing-payment-tender-types.html#admin-integration_10)

[Admin SVG icon](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/assets/images/workarea/admin/payment_icons/gift_card.svg)

[`Admin::PaymentGiftCardViewModel`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/view_models/workarea/admin/payment_gift_card_view_model.rb)

[Admin orders tenders partial](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/views/workarea/admin/orders/tenders/_gift_card.html.haml)

[Admin and Core translations](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/config/locales/en.yml#L3-L57)
