---
title: Implement a Primary Tender Type
excerpt: TODO
created_at: 2019/10/25
---

Implement a Primary Tender Type
======================================================================

[Primary payment tender types](/articles/payment-tender-types.html#primary-tender-types_3) are [payment tender types](/articles/payment-tender-types.html).
Base includes the credit card tender type, but you can add additional primary tender types, which shoppers can pay with instead of credit card.

Here's a procedure to implement one:

1. [Implement gateways](#gateways_1)
2. [Add tender type definition](#tender-type-definition_2)
3. [Integrate with Payment](#payment-integration_3)
4. [Implement each payment operation](#operation-implementations_4)
5. [Integrate into Storefront](#storefront-integration_5)
6. [Integrate into Admin](#admin-integration_6)

The examples use _Workarea PayPal_ v2.0.8 (
[gem](https://rubygems.org/gems/workarea-paypal/versions/2.0.8),
[docs](https://www.rubydoc.info/gems/workarea-paypal/2.0.8),
[source](https://github.com/workarea-commerce/workarea-paypal/tree/v2.0.8)
).


Gateways
----------------------------------------------------------------------

```ruby
# TODO pathname
module Workarea
  module YourTenderTypeVcrConfig
    # TODO
  end
end
```

```ruby
# your_engine/app/models/workarea/payment/your_tender_type_operation.rb [1][2]
module Workarea
  class Payment
    module YourTenderTypeOperation #[2]
      def gateway #[3]
        # TODO
      end

      def handle_gateway_errors #[4]
        begin
          yield
        rescue ActiveMerchant::ResponseError => error
          error.response
        rescue ActiveMerchant::ActiveMerchantError,
                ActiveMerchant::ConnectionError => error
          ActiveMerchant::Billing::Response.new(false, nil)
        end
      end
    end
  end
end
```

__[1]__

__[2]__

__[3]__

__[4]__
Use this for Active Merchant gateways.
Copied from `Workarea::Payment::CreditCardOperation`.
Use something else otherwise.

Workarea PayPal relies on two classes of gateways, both provided by Active Merchant:
[`ActiveMerchant::Billing::PaypalExpressGateway`](https://www.rubydoc.info/gems/activemerchant/1.99.0/ActiveMerchant/Billing/PaypalExpressGateway).
[`ActiveMerchant::Billing::BogusGateway`](https://www.rubydoc.info/gems/activemerchant/1.99.0/ActiveMerchant/Billing/BogusGateway).

The first talks to the remote PayPal service and therefore requires credentials.
This is used for production and any other environment for which you've provided PayPal credentials in Rails secrets.
For example, could set up a "sandbox" account and provide those credentials for QA/staging or even for local development.
When using this gateway in Workarea Commerce Cloud, you must add the endpoint(s) to the [proxy configuration](/articles/implementing-payment-tender-types.html#commerce-cloud-proxy_4).

The second is used for all environments that don't have PayPal credentials in secrets.
A good default for local development.

Also used for automated tests, but this isn't ideal.
Workarea PayPal automated tests use stubs and don't talk to the real endpoint.
[`Storefront::PaypalIntengrationTest`](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/test/integration/workarea/storefront/paypal_integration_test.rb).
This is an anti-pattern.
Use a current gateway testing pattern instead.

Operation implementations access the [gateway](/articles/implementing-payment-tender-types.html#gateways_1) by delegating `#gateway` to
[`Workarea::Paypal.gateway`](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/lib/workarea/paypal.rb#L7-L9).
This looks up the gateway in configuration, which is [autoconfigured](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/lib/workarea/paypal.rb#L11-L29) from an 
[initializer](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/config/initializers/workarea.rb#L7).
This means a single instance is re-used for each environment, which is an anti-pattern.
Use a current gateway access pattern instead.


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

[`Payment::Authorize::Paypal`](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/models/workarea/payment/authorize/paypal.rb)


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

[`Payment::Purchase::Paypal`](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/models/workarea/payment/purchase/paypal.rb)


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

[`Payment::Capture::Paypal`](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/models/workarea/payment/capture/paypal.rb)


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

[`Payment::Refund::Paypal`](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/models/workarea/payment/refund/paypal.rb)


Tender Type Definition
----------------------------------------------------------------------

[Tender Type Definition](/articles/implementing-payment-tender-types.html#tender-type-definition_6)

[`Payment::Tender::Paypal`](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/models/workarea/payment/tender/paypal.rb)


Payment Integration
----------------------------------------------------------------------

[Payment Integration](/articles/implementing-payment-tender-types.html#payment-integration_7)

[`Payment` decorator](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/models/workarea/payment.decorator)

[`PaymentTest` decorator](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/test/models/workarea/payment_test.decorator)

[Tender types configuration](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/config/initializers/workarea.rb#L1)


Storefront Integration
----------------------------------------------------------------------

[Storefront Integration](/articles/implementing-payment-tender-types.html#storefront-integration_9)

[`Storefront::Checkout::PlaceOrderController` decorator](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/controllers/workarea/storefront/checkout/place_order_controller.decorator)

[Storefront routes](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/config/routes.rb)

[`Storefront::PaypalController`](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/controllers/workarea/storefront/paypal_controller.rb)

[`Paypal::Setup`](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/services/workarea/paypal/setup.rb)

[`Paypal::SetupTest`](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/test/services/workarea/paypal/setup_test.rb)

[`Paypal::Update`](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/services/workarea/paypal/update.rb)

[`Paypal::UpdateTest`](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/test/services/workarea/paypal/update_test.rb)


[`Storefront::Checkout::PaymentViewModel` decorator](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/view_models/workarea/store_front/checkout/payment_view_model.decorator)

[`Storefront::CreditCardViewModel` decorator](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/view_models/workarea/store_front/credit_card_view_model.decorator)

[`Storefront::PaypalViewModel`](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/view_models/workarea/store_front/paypal_view_model.rb)


[Storefront checkouts payment partial](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/views/workarea/storefront/checkouts/_paypal_payment.html.haml)

[Configuration for Storefront checkouts payment partial](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/config/initializers/append_points.rb#L11-L14)

[Storefront checkouts error partial](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/views/workarea/storefront/checkouts/_paypal_error.html.haml)

[Configuration for Storefront checkouts error partial](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/config/initializers/append_points.rb#L6-L9)

[Storefront orders tenders partial](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/views/workarea/storefront/orders/tenders/_paypal.html.haml)

[Storefront API orders tenders partial](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/views/workarea/api/orders/tenders/_paypal.json.jbuilder)

[Storefront order mailer tenders partial (HTML)](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/views/workarea/storefront/order_mailer/tenders/_paypal.html.haml)

[Storefront order mailer tenders partail (text)](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/views/workarea/storefront/order_mailer/tenders/_paypal.text.haml)

[Storefront carts partial](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/views/workarea/storefront/carts/_paypal_checkout.html.haml)

[Configuration for Storefront carts payment partial](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/config/initializers/append_points.rb#L1-L4)


[`WORKAREA.updateCheckoutSubmitText`](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/assets/javascripts/workarea/storefront/paypal/modules/update_checkout_submit_text.js)

[Configuration for `WORKAREA.updateCheckoutSubmitText`](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/config/initializers/append_points.rb#L16-L19)

[PayPal SVG icon](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/assets/images/workarea/storefront/payment_icons/paypal.svg)


[Storefront translations](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/config/locales/en.yml#L9-L19)


[`Storefront::PlaceOrderIntegrationTest` decorator](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/test/integration/workarea/storefront/place_order_integration_test.decorator)

[`Storefront::PaypalIntengrationTest`](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/test/integration/workarea/storefront/paypal_integration_test.rb)

[`Storefront::CartSystemTest` decorator](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/test/system/workarea/storefront/cart_system_test.decorator)

[`Storefront::LoggedInCheckoutSystemTest` decorator](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/test/system/workarea/storefront/logged_in_checkout_system_test.decorator)


Admin Integration
----------------------------------------------------------------------

[Admin Integration](/articles/implementing-payment-tender-types.html#admin-integration_10)

[`Search::OrderText` decorator](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/models/workarea/search/order_text.decorator)

[`Admin::PaypalViewModel`](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/view_models/workarea/admin/paypal_view_model.rb)

[Admin orders tenders partial](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/views/workarea/admin/orders/tenders/_paypal.html.haml)

[PayPal SVG icon](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/assets/images/workarea/admin/payment_icons/paypal.svg)

[Admin translations](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/config/locales/en.yml#L4-L8)

[`Search::Admin::OrderTest` decorator](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/test/models/workarea/search/admin/order_test.decorator)
