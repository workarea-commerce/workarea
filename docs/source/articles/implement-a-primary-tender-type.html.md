---
title: Implement a Primary Tender Type
excerpt: How to implement a primary tender type, including gateway integration, operation implementations, payment model integration, Storefront integration, and Admin integration
created_at: 2019/12/03
---

Implement a Primary Tender Type
======================================================================

Workarea's base platform provides a single primary tender type: _credit card_.
However, a retailer may want to offer its customers alternative payment options, such as [PayPal](https://www.paypal.com) or [Afterpay](https://www.afterpay.com).
To do so, application developers can extend their applications with additional primary tender types.

Workarea provides many plugins that do this work for you for various payment services.
You should use one of these plugins if you can.
However, there are many such payment services, and a retailer may choose a service for which a Workarea plugin does not yet exist.

In that case, you will need to implement the primary tender type yourself, either directly within an application or within a plugin that can be re-used across applications.
This document provides the procedure to complete this work, which can be summarized as:

1. [Integrate the _gateway_](#gateway-integration) for the payment service into the Workarea application
2. [Define _operation implementations_](#operation-implementations) which use the gateway to process payments of the new type
3. [Integrate the tender type with the _payment model_](#payment-model-integration) to manage tender-specific data and logic
6. [Integrate the tender type with the _Storefront_](#storefront-integration) to collect and show data specific to the tender type
7. [Integrate the tender type with the _Admin_](#admin-integration) to facilitate display and administration for the new tender type


Gateway Integration
----------------------------------------------------------------------

A Workarea application communicates with a payment service through a _gateway_ object.
So you must identify and locate/install the gateway class(es) you need for your chosen payment service.
Consult with the retailer and the payment service provider if necessary.

(
In rare cases, you will need to write your own gateway class(es).
That task is outside the scope of this document.
)

Once you have access to the necessary gateway class(es), you must integrate the gateway into the Workarea application.
To do so, complete the following steps:

1. [Define a _gateway module method_](#gateway-module-method) to provide a consistent interface for initializing the gateway when needed
2. [Edit the _proxy configuration_](#proxy-configuration) to allow communication with the payment service over the network (Commerce Cloud only)


### Gateway Module Method

To process payments, a Workarea application needs to initialize the appropriate gateway, which will likely differ by environment or use case (e.g. production, development, QA, automated testing).

For this purpose, you should provide a module for your tender type and implement a _gateway module method_ that encapsulates the gateway initialization logic.
The following sections provide boilerplate for this module method, as well as a concrete example.


#### Gateway Module Method Boilerplate

For your gateway module method, start with the following boilerplate and customize it as necessary for your specific implementation.
Refer to the inline annotations for guidance.

```ruby
# your_engine/lib/workarea/your_tender_type.rb [1][2]

module Workarea
  module YourTenderType #[2]
    def self.gateway #[3]
      if Rails.env.test?
        gateway_using_vcr_cassettes
      elsif credentials.present?
        gateway_using_network
      else
        local_gateway
      end
    end

    def self.gateway_using_network #[4]
      YourTenderType::Gateway.new( #[5]
        credentials.deep_symbolize_keys
      )
    end

    def self.gateway_using_vcr_cassettes #[4]
      YourTenderType::Gateway.new( #[6]
        merchant_id: 'foo',
        private_key: 'bar',
        baz: 'qux'
      )
    end

    def self.local_gateway #[4]
      YourTenderType::BogusGateway.new #[7]
    end

    def self.credentials #[4]
      Rails.application.secrets.your_tender_type
    end
  end
end
```

__[1]__
Replace the pathname `your_engine` with the pathname for your application or plugin, such as `~/discount-supercenter` or `~/workarea-deferred-pay`.
_
__[2]__
Replace `your_tender_type` and `YourTenderType` with the name of your tender type, for example: `deferred_pay` and `DeferredPay`.

__[3]__
Implement `.gateway` to lazily init and return a gateway object.
Replace the logic here with your own use cases.
You may want to vary your gateway initialization logic based on credentials, rails environment, current site (if multi site), or other application states or combination of states.
Work with your retailer and/or other partners to determine the correct gateway class and arguments.

__[4]__
These additional methods are used only to implement `.gateway` more clearly.
Use "private" methods of this sort if it makes sense for your gateway.
Remove whatever methods you don't need.

__[5]__
Replace `YourTenderType::Gateway` with the appropriate gateway class, and initialize the object with the appropriate arguments.
Refer to your gateway's documentation.
The boilerplate demonstrates the common pattern of fetching the gateway's credentials from [Rails secrets](https://api.rubyonrails.org/v5.2/classes/Rails/Application.html#method-i-secrets).
(Alternatively, use [Rails credentials](https://api.rubyonrails.org/v5.2/classes/Rails/Application.html#method-i-credentials).)

__[6]__
Replace `YourTenderType::Gateway` with the appropriate gateway class, and initialize the object with the appropriate arguments.
The boilerplate uses the same gateway class for automated testing as it does for production and production-like (e.g. QA, staging) use cases.
When using this pattern, start with actual credentials (via
[Rails secrets](https://api.rubyonrails.org/v5.2/classes/Rails/Application.html#method-i-secrets) or
[Rails credentials](https://api.rubyonrails.org/v5.2/classes/Rails/Application.html#method-i-credentials))
so you can communicate with the payment service over the network and record [vcr](https://rubygems.org/gems/vcr) cassettes.
After the cassettes are recorded, remove all credentials (or use dummy values if the arguments are required).
The credentials are no longer needed since the responses will be read from the cassettes.
__Don't commit secrets to your repository!__

__[7]__
If available for your payment service, default to a bogus gateway that does not require credentials or communicate over the network.


#### Gateway Module Method Example

To see a concrete example of a gateway module method, refer to [`Workarea::Afterpay.gateway` from Workarea Afterpay 2.1.0](https://github.com/workarea-commerce/workarea-afterpay/blob/v2.1.0/lib/workarea/afterpay.rb#L48-L59).

With Workarea Afterpay 2.1.0 installed, calling `Workarea::Afterpay.gateway` returns an object of type [`Workarea::Afterpay::Gateway`](https://github.com/workarea-commerce/workarea-afterpay/blob/v2.1.0/lib/workarea/afterpay/gateway.rb) or [`Workarea::Afterpay::BogusGateway`](https://github.com/workarea-commerce/workarea-afterpay/blob/v2.1.0/lib/workarea/afterpay/bogus_gateway.rb).


### Proxy Configuration

Workarea Commerce Cloud applications must additionally edit the _proxy configuration_ to allow communication with the payment service over the network.

Use the Workarea CLI to access and edit the proxy configuration.
Add the endpoint(s) for the payment service.
See [CLI, Edit](/cli.html#edit).

(
This step may not apply to applications hosted outside of Workarea Commerce Cloud.
Consult your hosting team or provider.
)


Operation Implementations
----------------------------------------------------------------------

After integrating the payment service gateway, you can use the gateway to process payments.
The objects that handle these transactions are called _operation implementations_.
Each operation implementation class defines `#complete!`, which completes transactions of this type, and `#cancel!`, which rolls back completed transactions when necessary.

You must define each operation implementation for your tender type, which you can do in the following steps:

1. [Implement a _tender-specific operation mixin_](#tender-specific-operation-mixin) to encapsulate shared logic for operations of your tender type
2. [Implement _authorize_](#authorize-implementation) for your tender type
3. [Implement _purchase_](#purchase-implementation) for your tender type
4. [Implement _capture_](#capture-implementation) for your tender type
5. [Implement _refund_](#refund-implementation) for your tender type

Be aware that operation implementations depend on data from the payment model.
Therefore, the _Operation Implementations_ step overlaps with the [Payment Model Integration](#payment-model-integration) step.
You will likely need to develop them concurrently.


### Tender-Specific Operation Mixin

Each operation implementation for your tender type will include the module [`OperationImplementation`](https://github.com/workarea-commerce/workarea/blob/v3.5.0/core/app/models/workarea/payment/operation_implementation.rb), which provides the basic interface for this type of object.
However, your tender type will require additional logic that is shared by all of its operation implementations, primarily knowledge about the payment service gateway.

You must therefore implement a tender-specific mixin to be included in all operation implementations for this type.
Include in the mixin a reference to the gateway object, exception handling for the gateway (if applicable), and any other shared logic.

The following sections provide boilerplate for this mixin, followed by a concrete example.


#### Tender-Specific Operation Mixin Boilerplate

Start with the following boilerplate and customize it for your specific implementation.

```ruby
# your_engine/app/models/workarea/payment/your_tender_type_operation.rb [1][2]

module Workarea
  class Payment
    module YourTenderTypeOperation #[2]
      def gateway #[3]
        Workarea::YourTenderType.gateway #[2]
      end

      def handle_gateway_errors #[4]
        begin
          yield #[5]
        rescue YourTenderType::Gateway::ConnectionError => error #[6]
          YourTenderType::Gateway::Response.new(false, nil) #[7]
        end
      end
    end
  end
end
```

__[1]__
Replace the pathname `your_engine` with the pathname for your application or plugin, such as `~/discount-supercenter` or `~/workarea-deferred-pay`.

__[2]__
Replace `your_tender_type_operation` and `YourTenderTypeOperation` with a name matching your tender type, for example: `deferred_pay_operation` and `DeferredPayOperation`.

__[3]__
Implement `#gateway` as an alias for the gateway module method you already implemented.
See section [Gateway Module Method](#gateway-module-method).
Keep the gateway initialization logic in that module (rather than here) so it can be shared by automated tests and any other code that requires gateway access.

__[4]__
Implement `#handle_gateway_errors` to "wrap" API calls to the gateway.
This method should encapsulate all gateway exceptions you want to handle.
For an example, refer to [`Payment::CreditCardOperation#handle_active_merchant_errors` from Workarea Core 3.5.0](https://github.com/workarea-commerce/workarea/blob/v3.5.0/core/app/models/workarea/payment/credit_card_operation.rb#L4-L13), which encapsulates similar logic for Active Merchant gateways.

__[5]__
Write this method to take a block so that it can "wrap" API calls to the gateway.

__[6]__
Enumerate here all the exceptions you'd like to handle.
Check the documentation for your gateway for possible exceptions.
Use separate `rescue` statements if needed to vary the return value by exception.

__[7]__
Return an object type that is consistent with API responses from your gateway.
See __[11]__, below.
The examples in this document assume a custom response object, so that is used here.


#### Tender-Specific Operation Mixin Example

To see a concrete example of a tender-specific operation mixin, refer to [`Payment::AfterpayPaymentGateway` from Workarea Afterpay 2.1.0](https://github.com/workarea-commerce/workarea-afterpay/blob/v2.1.0/app/models/workarea/payment/afterpay_payment_gateway.rb).

This module is named differently from the boilerplate, but it performs the same function.
It does not implement `#handle_gateway_errors` because the error handling for this gateway is operation-specific.
This plugin writes error handling into each operation implementation instead.


### Authorize Implementation

After implementing the shared logic, you can move on to the first transaction type: _authorize_.

The following sections provide boilerplate and an example for an _authorize_ operation implementation.


#### Authorize Implementation Boilerplate

Start with the following boilerplate and customize it as necessary.
Refer to the inline annotations for guidance.

```ruby
# your_engine/app/models/workarea/payment/authorize/your_tender_type.rb [1][2]
module Workarea
  class Payment
    module Authorize
      class YourTenderType #[2]
        include OperationImplementation #[8]
        include YourTenderTypeOperation #[9]

        def complete! #[10]
          gateway_response = #[11]
            handle_gateway_errors do #[12]
              gateway.authorize( #[13]
                transaction.amount.cents, #[14]
                tender.foo,
                tender.bar
              )
            end

          transaction.response = #[15]
            ActiveMerchant::Billing::Response.new( #[16]
              gateway_response.success?, #[17]
              gateway_response.message
            )
        end

        def cancel! #[18]
          return unless transaction.success? #[19]

          gateway_response = #[20]
            handle_gateway_errors do #[12]
              gateway.void( #[21]
                transaction.response.authorization #[22]
              )
            end

          transaction.cancellation = #[23]
            ActiveMerchant::Billing::Response.new( #[16]
              gateway_cancellation.success?, #[17]
              gateway_cancellation.message
            )
        end
      end
    end
  end
end
```

__[8]__
You must include this module to have access to `transaction`, `tender`, and `options`, which depend on the [Payment Model Integration](#payment-model-integration).

__[9]__
Rename this module to be specific to your tender type, such as `DeferredPayOperation`.

__[10]__
You must implement `complete!` to fulfill the operation implementation contract.

__[11]__
Ultimately, you must assign `transaction.response` to fulfill the contract for `#complete!`.
See __[15]__.
That value is derived from a response from the gateway, so store the gateway's response for later use.
This example assumes the gateway's response is not already an `ActiveMerchant::Billing::Response`.
See __[16]__.

__[12]__
If you implemented gateway exception handling in __[4]__, remember to wrap all calls to the gateway with this method.

__[13]__
Use the appropriate API call for your gateway.
See __[3]__.
The correct API call is often `authorize`, but refer to your gateway's documentation.

__[14]__
Pass the proper arguments for the gateway API call.
The first argument is typically the amount in cents.
To construct this data, you have access to `transaction`, `tender`, and `options`, which depend on the [Payment Model Integration](#payment-model-integration).

__[15]__
You must assign `transaction.response` to fulfill the contract for `#complete!`.

__[16]__
The value assigned must be an object of type [`ActiveMerchant::Billing::Response`](https://www.rubydoc.info/gems/activemerchant/1.102.0/ActiveMerchant/Billing/Response).
The provided boilerplate assumes your gateway does not return this type and therefore constructs an instance manually.

__[17]__
Construct the arguments for the Active Merchant response from the original gateway response.
The interface of `gateway_response` will vary by gateway.

__[18]__
You must implement `cancel!` to fulfill the operation implementation contract.

__[19]__
You must return early if the transaction wasn't successful to fulfill the contract for `#cancel!`.

__[20]__
Ultimately, you must assign `transaction.cancellation` to fulfill the contract for `#cancel!`.
See __[23]__.
That value is derived from a response from the gateway, so store the gateway's response for later use.
This example assumes the gateway's response is not already an `ActiveMerchant::Billing::Response`.
See __[16]__.

__[21]__
Use the appropriate API call for your gateway.
See __[3]__.
The correct API call is often `void`, `cancel`, or `refund`, but refer to your gateway's documentation.

__[22]__
Pass the proper arguments for the gateway API call.
The first argument is typically a reference to the original authorization, such as `transaction.response.authorization` or `transaction.response.params['transaction_id']`.
To construct this data, you have access to `transaction`, `tender`, and `options`, which depend on the [Payment Model Integration](#payment-model-integration).

__[23]__
You must assign `transaction.cancellation` to fulfill the contract for `#cancel!`.


#### Authorize Implementation Example

Here is a concrete example of an _authorize_ operation implementation used in production:

[`Payment::Authorize::Afterpay` from Workarea Afterpay 2.1.0](https://github.com/workarea-commerce/workarea-afterpay/blob/v2.1.0/app/models/workarea/payment/authorize/afterpay.rb)


### Purchase Implementation

The following sections provide boilerplate and an example for a _purchase_ operation implementation.


#### Purchase Implementation Boilerplate

Start with the following boilerplate and customize it as necessary.
Refer to the inline annotations for guidance.

```ruby
# your_engine/app/models/workarea/payment/purchase/your_tender_type.rb [1][2]
module Workarea
  class Payment
    module Purchase
      class YourTenderType #[2]
        include OperationImplementation #[8]
        include YourTenderTypeOperation #[9]

        def complete! #[10]
          gateway_response = #[11]
            handle_gateway_errors do #[12]
              gateway.purchase( #[24]
                transaction.amount.cents, #[14]
                tender.foo,
                tender.bar
              )
            end

          transaction.response = #[15]
            ActiveMerchant::Billing::Response.new( #[16]
              gateway_response.success?, #[17]
              gateway_response.message
            )
        end

        def cancel! #[18]
          return unless transaction.success? #[19]

          gateway_response = #[20]
            handle_gateway_errors do #[12]
              gateway.void( #[21]
                transaction.response.authorization #[22]
              )
            end

          transaction.cancellation = #[23]
            ActiveMerchant::Billing::Response.new( #[16]
              gateway_cancellation.success?, #[17]
              gateway_cancellation.message
            )
        end
      end
    end
  end
end
```

__[24]__
Use the appropriate API call for your gateway.
See __[3]__.
The correct API call is often `purchase`, but refer to your gateway's documentation.


#### Purchase Implementation Example

Here is a concrete example of a purchase operation implementation used in production:

[`Payment::Purchase::Afterpay` from Workarea Afterpay 2.1.0](https://github.com/workarea-commerce/workarea-afterpay/blob/v2.1.0/app/models/workarea/payment/purchase/afterpay.rb)


### Capture Implementation

The following sections provide boilerplate and an example for a _capture_ operation implementation.


#### Capture Implementation Boilerplate

Start with the following boilerplate and customize it as necessary.
Refer to the inline annotations for guidance.

```ruby
# your_engine/app/models/workarea/payment/capture/your_tender_type.rb [1][2]
module Workarea
  class Payment
    module Capture
      class YourTenderType #[2]
        include OperationImplementation #[8]
        include YourTenderTypeOperation #[9]

        def complete! #[10]
          validate_reference! #[25]

          gateway_response = #[11]
            handle_gateway_errors do #[12]
              gateway.capture( #[26]
                transaction.amount.cents, #[27]
                transaction.reference.response.authorization
              )
            end

          transaction.response = #[15]
            ActiveMerchant::Billing::Response.new( #[16]
              gateway_response.success?, #[17]
              gateway_response.message
            )
        end

        def cancel! #[28]
          #noop
        end
      end
    end
  end
end
```

__[25]__
You must use `validate_reference!` for a capture operation unless this does not apply to your gateway.

__[26]__
Use the appropriate API call for your gateway.
See __[3]__.
The correct API call is often `capture`, but refer to your gateway's documentation.

__[27]__
Pass the proper arguments for the gateway API call.
The first argument is typically the amount in cents.
The second argument is typically a reference to the original transaction's authorization, such as `transaction.reference.response.authorization` or `transaction.reference.response.params['transaction_id']`.
To construct this data, you have access to `transaction`, `tender`, and `options`, which depend on the [Payment Model Integration](#payment-model-integration).

__[28]__
For most payment services, it doesn't make sense to cancel a capture, so this method should be implemented to do nothing.
However, if there is an appropriate response for your gateway
(e.g.  [Workarea PayPal issues a refund](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.9/app/models/workarea/payment/capture/paypal.rb#L26)),
you should implement it here, using other `#cancel!` implementations for inspiration.


#### Capture Implementation Example

Here is a concrete example of a capture operation implementation used in production:

[`Payment::Capture::Afterpay` from Workarea Afterpay 2.1.0](https://github.com/workarea-commerce/workarea-afterpay/blob/v2.1.0/app/models/workarea/payment/capture/afterpay.rb)


### Refund Implementation

The following sections provide boilerplate and an example for a _refund_ operation implementation.


#### Refund Implementation Boilerplate

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
Use the appropriate API call for your gateway.
See __[3]__.
The correct API call is often `refund`, but refer to your gateway's documentation.

__[25]__
For most payment services, it doesn't make sense to cancel a refund, so this method should be implemented to do nothing.
However, if there is an appropriate response for your gateway
(e.g. [Workarea Gift Card re-purchases the amount](https://github.com/workarea-commerce/workarea-gift-cards/blob/v4.0.0/app/models/workarea/payment/refund/gift_card.rb#L20)),
you should implement it here, using other `#cancel!` implementations for inspiration.


#### Refund Implementation Example

Here is a concrete example of a capture operation implementation used in production:

[`Payment::Refund::Afterpay` from Workarea Afterpay 2.1.0](https://github.com/workarea-commerce/workarea-afterpay/blob/v2.1.0/app/models/workarea/payment/refund/afterpay.rb)


Payment Model Integration
----------------------------------------------------------------------

To complete the implementation of your tender type, you must collect tender-specific data from the customer through the Storefront and pass it to the payment service via the operation implementations.
This data is persisted to a [`Payment`](https://github.com/workarea-commerce/workarea/blob/v3.5.0/core/app/models/workarea/payment.rb) model, which also defines related logic.

You must therefore integrate your tender type with the payment model, which requires three steps:

1. [Define a _tender model_](#embedded-tender-model) to embed within the payment model
2. [Decorate the _payment model_](#payment-decorator) to embed the tender model and provide supporting methods
3. [Add a _tender types initializer_](#tender-types-initializer) to add your tender type to the embedded collection of all tenders

The _Payment Model Integration_ is effectively a bridge between the [Operation Implementations](#operation-implementations) and [Storefront Integration](#storefront-integration).
You will likely need to develop those steps concurrently.


### Embedded Tender Model

The `Payment` model that represents the payment for each order embeds a collection of tender models, which store the data and logic specific to each tender.
These embedded tenders are of varying types, but each model is a subclass of [`Payment::Tender`](https://github.com/workarea-commerce/workarea/blob/v3.5.0/core/app/models/workarea/payment/tender.rb).

You must define a model to represent your new tender type.
The following sections provide boilerplate for this model and a concrete example.


#### Embedded Tender Model Boilerplate

Start with the following boilerplate, and customize your model definition as needed.

```ruby
# your_engine/app/models/workarea/payment/tender/your_tender_type.rb [1][2]

module Workarea
  class Payment::Tender::YourTenderType < Payment::Tender #[2][3]
    field :indentifier, type: String #[4]

    def slug #[5]
      :your_tender_type
    end
    
    # [4]
    #
    # def foo
    # end
    #
    # def bar
    # end
  end
end
```

__[1]__
Replace the pathname `your_engine` with the pathname for your application or plugin, such as `~/discount-supercenter` or `~/workarea-deferred-pay`.

__[2]__
Replace `your_tender_type` and `YourTenderType` with the name of your tender type, for example: `deferred_pay` and `DeferredPay`.

__[3]__
You must inherit from `Payment::Tender`, which provides the base interface for a tender type.

__[4]__
Implement the fields (i.e. data) and methods (i.e. logic) required by your tender type.
Consider any data that must be collected and passed on to the payment service to complete a transaction and any data you may need for flow control or display in the Storefront.
Store here any data you need to complete your operation implementations, Storefront integration, and Admin integration.
At a minimum, you will likely need to store a string representing a specific tender, such as a card number or customer ID.
Replace `:identifier` with the appropriate field name and `foo` and `bar` with your own methods (or remove them if not needed).

__[5]__
You must implement `#slug` to fulfill the tender contract.
It should return a symbol that uniquely identifies the tender type.
The value is also transformed and displayed in the Storefront and Admin UIs.


#### Embedded Tender Model Example

Here is a concrete example of a tender model used in production:

[`Payment::Tender::Afterpay` from Workarea Afterpay 2.1.0](https://github.com/workarea-commerce/workarea-afterpay/blob/v2.1.0/app/models/workarea/payment/tender/afterpay.rb)

In this example, `:token` identifies the tender, `:ready_to_capture` is used for Storefront flow control, and `:installment_price` is used for Storefront display.


### Payment Decorator

For each embedded tender, the `Payment` model provides methods to set, clear, and query the presence of a tender of that type.

Also, since only one primary tender type may be present at any given time, the setter for each primary tender type must clear the other primary tender types.

[Decorate](/articles/decoration.html) the `Payment` model to define the setter, clearer, and query for your embedded tender; and decorate the setters for each additional primary tender type.


#### Payment Decorator Boilerplate

```ruby
#  your_engine/app/models/workarea/payment.decorator [1]

module Workarea
  decorate Payment, with: :your_engine do #[2]
    decorated do
      embeds_one :your_tender_type, #[3]
        class_name: 'Workarea::Payment::Tender::YourTenderType' #[4]
    end

    def set_your_tender_type(attrs) #[5]
      clear_credit_card #[6]

      # [7]
      #
      # clear_foo_type
      # clear_bar_type

      build_your_tender_type unless your_tender_type #[8]
      your_tender_type.attributes = attrs.slice(
        :foo,
        :bar
      )
      save
    end

    def clear_your_tender_type #[9]
      self.your_tender_type = nil
      save
    end

    def your_tender_type? #[10]
      your_tender_type.present?
    end

    def set_credit_card(*) #[11]
      clear_your_tender_type
      super
    end

    # [12]
    #
    # def set_foo_type(*)
    #   clear_your_tender_type
    #   super
    # end
    #
    # def set_bar_type(*)
    #   clear_your_tender_type
    #   super
    # end
  end
end
```

__[1]__
Replace the pathname `your_engine` with the pathname for your application or plugin, such as `~/discount-supercenter` or `~/workarea-deferred-pay`.

__[2]__
If developing an application, you can omit the `with` argument.
If developing a plugin, replace `your_engine` with a slug identifying your plugin, such as `deferred_pay`.

__[3]__
Replace `:your_tender_type` with a symbol that matches the embedded tender, such as `:deferred_pay`.
(See [Embedded Tender Model](#embedded-tender-model).)

__[4]__
Replace `'Workarea::Payment::Tender::YourTenderType'` with the class name of the embedded tender model, such as `'Workarea::Payment::Tender::DeferredPay'`.
(See [Embedded Tender Model](#embedded-tender-model).)

__[5]__
Define a setter for your embedded tender document.
Name the method after your tender type, for example: `set_deferred_pay`.

__[6]__
When setting this tender you must "unset" all other primary tenders.
Always unset credit card, since it's the platform's default primary tender.

__[7]__
If you're developing within an application, additional primary tender types may exist.
Clear all other primary tenders.

__[8]__
Build the embedded tender, mutate it as necessary, and save the payment.
Replace the substring `your_tender_type` with the name of your embedded tender, for example: `build_deferred_pay`.
(This method name relies on meta programming from the Mongoid library).

__[9]__
You should provide this method by convention.
Replace the substring `your_tender_type` with the name of your embedded tender, for example: `clear_deferred_pay`.

__[10]__
You should provide this method by convention.
Replace the substring `your_tender_type` with the name of your embedded tender, for example: `deferred_pay?`.

__[11]__
Decorate the setter for the credit card tender to clear the new primary tender type when the credit card tender is set.
There can be only one primary tender set on a payment.

__[12]__
If you're developing within an application, additional primary tender types may exist.
Extend the setter for each additional primary tender so that setting it will clear the new primary tender.


#### Payment Decorator Example

Here is an example of a payment decorator used in production:

[`Payment` decorator from Workarea Afterpay 2.1.0](https://github.com/workarea-commerce/workarea-afterpay/blob/v2.1.0/app/models/workarea/payment.decorator)


### Tender Types Initializer

The method [`Payment#tenders`](https://github.com/workarea-commerce/workarea/blob/v3.5.0/core/app/models/workarea/payment.rb#L67-L71) returns a collection of all the tenders embedded on that payment.
The tenders in this collection are of different types, and the order in which they appear is the order in which the tenders will be charged/refunded during payment processing.

You must [configure](/articles/configuration.html) `Workarea.config.tender_types` to declare where tenders of your new type should appear within this collection.
All primary tenders must be placed _after_ all advance payment tenders.
The order among primary tenders isn't important, since only one can be present on a payment at any given time.

You should therefore _append_ your tender type to the config from an initializer.
Refer to the following boilerplate and example.


#### Tender Types Initializer Boilerplate

Start with the following boilerplate for your initializer.

```ruby
# your_engine/config/initializers/tender_types.rb [1][2]

Workarea.config.tender_types.append(:your_tender_type) #[3]
```

__[1]__
Replace the pathname `your_engine` with the pathname for your application or plugin, such as `~/discount-supercenter` or `~/workarea-deferred-pay`.

__[2]__
If desired, change the name of the initializer or add the code that follows to an existing initializer.

__[3]__
Replace `:your_tender_type` with the symbolized name of your embedded tender (as implemented on the `Payment` model), such as `:deferred_pay`.


#### Tender Types Initializer Example

To see a concrete example of this type of initializer, refer to the following:

[`workarea.rb` initializer from Workarea Afterpay 2.1.0](https://github.com/workarea-commerce/workarea-afterpay/blob/v2.1.0/config/initializers/workarea.rb#L4)


Storefront Integration
----------------------------------------------------------------------

The Storefront allows customers to choose their primary tender type during checkout, and it displays information about the tender of that type when showing the placed order.
During checkout, the Storefront UI may collect tender-specific data from the shopper, either from explicit fields (e.g. card number) or hidden/implicit parameters (e.g. Afterpay token).
A tender type may require deeper Storefront integration, such as changes to checkout flow (e.g. to go "offsite" for payment data collection), changes to cart (e.g. "Pay with X" button), or changes to product detail pages (e.g. pay-by-installment pricing).

Primary tender types vary considerably in their Storefront integrations, but there are a few commonalities.
To integrate your tender type into the Storefront, complete the following:

1. [Decorate the Storefront's _checkout payment view model_](#checkout-payment-view-model) to ensure the new tender type doesn't impact existing behavior
2. [Append a _checkout payment partial_](#checkout-payment-partial) to add the new tender type to the list of available payment options in checkout
3. [Create _order tender partials_](#order-tender-partials) to handle the display of the new tender type when showing placed orders
4. [Complete other _tender-specific integrations_](#tender-specific-integrations) as needed for your tender type

Data collected by the _Storefront Integration_ is persisted by the [Payment Model Integration](#payment-model-integration).
These steps therefore overlap.
You will likely need to develop them concurrently.


### Checkout Payment View Model

The payment step of checkout presents the primary tender types within a radio button set.
The set includes one entry for each saved credit card (if any) and one entry for a new credit card, which expands when selected to show the "new credit card" fields.

Each additional primary tender type must add itself to this list and must also ensure it doesn't break the expand/collapse functionality for the "new credit card" fields.
That functionality relies on [`Storefront::Checkout::PaymentViewModel#using_new_card?`](https://github.com/workarea-commerce/workarea/blob/v3.5.0/storefront/app/view_models/workarea/storefront/checkout/payment_view_model.rb#L80-L88), which is aware of only the credit card tender type.

To maintain the existing expand/collapse behavior for the "new credit card" option, you must [decorate](/articles/decoration.html) this method to make it aware of your new primary tender type.
Using the original implementation and the follow example as references, create your own decorator that incorporates your tender type into the `#using_new_card?` implementation.

[`Storefront::Checkout::PaymentViewModel` decorator from Workarea Afterpay 2.1.0](https://github.com/workarea-commerce/workarea-afterpay/blob/v2.1.0/app/view_models/workarea/storefront/checkout/payment_view_model.decorator#L21-L23) (fragment):

```ruby
module Workarea
  decorate Storefront::Checkout::PaymentViewModel, with: :afterpay do
    decorated do
      delegate :afterpay?, to: :payment
    end

    def using_new_card?
      super && !afterpay?
    end
  end
end
```


### Checkout Payment Partial

In the Storefront, Workarea presents the primary tender types as a list of payment options, within a radio button set.
You must [append](/articles/appending.html) to this radio button set a partial that adds a radio button for your new tender type.

Using the following examples as a reference, implement the necessary partial and initializer to append the partial.

[`storefront/checkouts/_afterpay_payment.html.haml` partial from Workarea Afterpay 2.1.0](https://github.com/workarea-commerce/workarea-afterpay/blob/v2.1.0/app/views/workarea/storefront/checkouts/_afterpay_payment.html.haml):

```haml
-if @step.afterpay.show?
  -if @step.afterpay.order_total_in_range?
    .checkout-payment__primary-method{ class: ('checkout-payment__primary-method--selected' if @step.afterpay?) }
      .button-property
        = hidden_field_tag 'from_checkout', 'from_checkout', id: nil
        .value= radio_button_tag 'payment', 'afterpay', step.afterpay?, data: { afterpay_token: (@step.afterpay_token if @step.allow_redirect_to_afterpay?), afterpay_country: @step.afterpay.afterpay_country }
        = label_tag 'payment[afterpay]', nil, class: 'button-property__name' do
          %span.button-property__text= image_tag('https://static.afterpay.com/integration/product-page/logo-afterpay-colour.png')
      %p.checkout-payment__primary-method-description
        %span #{t('workarea.storefront.checkouts.afterpay', installment_price: number_to_currency(@step.afterpay.installment_price), installment_count: Workarea.config.afterpay[:installment_count])}
        %span= link_to(t('workarea.storefront.afterpay.learn_more'), learn_more_link(@cart.total_price), data: { popup_button: { width: 600, height: 800 }})
      %p
        %span= t('workarea.storefront.afterpay.on_continue')
  - else
    %p
      #{image_tag('https://static.afterpay.com/integration/product-page/logo-afterpay-colour.png')}
      #{t('workarea.storefront.afterpay.ineligible_order_total', min: number_to_currency(@cart.afterpay.min_price), max: number_to_currency(@cart.afterpay.max_price))}
```

At a minimum, this partial must include a radio button whose name is `payment` and whose value is your tender type.
That much will allow shoppers to select your tender type while ensuring other primary tender types will be deselected.

It may need to include additional fields, like a number or other identifying information that you need to collect for the tender type.
In this case, refer to the base implementation of the "new credit card" payment option.

[`appends.rb` initializer from Workarea Afterpay 2.1.0](https://github.com/workarea-commerce/workarea-afterpay/blob/v2.1.0/config/initializers/appends.rb#L6-L9) (fragment):

```ruby
Workarea::Plugin.append_partials(
  'storefront.payment_method',
  'workarea/storefront/checkouts/afterpay_payment'
)
```


### Order Tender Partials

When showing placed orders in the Storefront, Workarea needs to know how to display information about tenders of your new type.
This information includes the type of tender, the amount, and tender-specific details such as the number of installments or a gift card number.
When displaying this information, Workarea automatically looks for specific partials to render.

You must create these partials for your tender type.
Refer to the following examples, and create corresponding partials for your tender type implementation.

[`storefront/orders/tenders/_afterpay.html.haml` partial from Workarea Afterpay 2.1.0](https://github.com/workarea-commerce/workarea-afterpay/blob/v2.1.0/app/views/workarea/storefront/orders/tenders/_afterpay.html.haml):

```haml
.data-card
  .data-card__cell
    %p.data-card__line
      = t('workarea.afterpay.tender_description', installment_price: number_to_currency(tender.installment_price), installment_count: Workarea.config.afterpay[:installment_count])
```

[`storefront/order_mailer/tenders/_afterpay.html.haml` partial from Workarea Afterpay 2.1.0](https://github.com/workarea-commerce/workarea-afterpay/blob/v2.1.0/app/views/workarea/storefront/order_mailer/tenders/_afterpay.html.haml):

```haml
%p{ style: "margin: 0 0 6px; font: 13px/1.5 arial; color: #{@config.text_color};" }
  = t('workarea.afterpay.tender_description', installment_price: number_to_currency(tender.installment_price), installment_count: Workarea.config.afterpay[:installment_count])
```


### Tender-Specific Integrations

Your Storefront integration will likely require more&mdash;possibly much more&mdash;than the preceding steps, but the remaining work will be specific to your tender type and difficult to outline here as a general procedure.
You may need to implement Storefront routes, controllers, views, view models, helpers, assets, libraries, configuration, translations, and tests to complete your integration.
These extensions may be limited to checkout or may start "earlier", such as in the cart or on product detail pages.

Work with your retailer and payment service provider to determine what additional work is necessary.
Then refer to concrete examples (e.g. Workarea plugin sources) to see what similar integrations look like.

For an example, review the following files, which are the more significant aspects of the [Workarea Afterpay 2.1.0](https://github.com/workarea-commerce/workarea-afterpay/tree/v2.1.0) Storefront integration:

* [`config/routes.rb`](https://github.com/workarea-commerce/workarea-afterpay/blob/v2.1.0/config/routes.rb)
* [`app/controllers/workarea/storefront/checkout/place_order_controller.decorator`](https://github.com/workarea-commerce/workarea-afterpay/blob/v2.1.0/app/controllers/workarea/storefront/checkout/place_order_controller.decorator)
* [`app/controllers/workarea/storefront/afterpay_controller.rb`](https://github.com/workarea-commerce/workarea-afterpay/blob/v2.1.0/app/controllers/workarea/storefront/afterpay_controller.rb)
* [`app/controllers/workarea/storefront/afterpay_dialog_controller.rb`](https://github.com/workarea-commerce/workarea-afterpay/blob/v2.1.0/app/controllers/workarea/storefront/afterpay_dialog_controller.rb)
* [`app/views/workarea/storefront/afterpay_dialog/show.html.haml`](https://github.com/workarea-commerce/workarea-afterpay/blob/v2.1.0/app/views/workarea/storefront/afterpay_dialog/show.html.haml)
* [`app/views/workarea/storefront/style_guides/components/_afterpay_dialog.html.haml`](https://github.com/workarea-commerce/workarea-afterpay/blob/v2.1.0/app/views/workarea/storefront/style_guides/components/_afterpay_dialog.html.haml)
* [`app/assets/stylesheets/workarea/storefront/components/_afterpay_dialog.scss`](https://github.com/workarea-commerce/workarea-afterpay/blob/v2.1.0/app/assets/stylesheets/workarea/storefront/components/_afterpay_dialog.scss)
* [`app/assets/javascripts/workarea/storefront/afterpay/modules/afterpay_redirect.js`](https://github.com/workarea-commerce/workarea-afterpay/blob/v2.1.0/app/assets/javascripts/workarea/storefront/afterpay/modules/afterpay_redirect.js)
* [`app/views/workarea/storefront/carts/_afterpay.html.haml`](https://github.com/workarea-commerce/workarea-afterpay/blob/v2.1.0/app/views/workarea/storefront/carts/_afterpay.html.haml)
* [`app/view_models/workarea/storefront/product_view_model.decorator`](https://github.com/workarea-commerce/workarea-afterpay/blob/v2.1.0/app/view_models/workarea/storefront/product_view_model.decorator)
* [`app/views/workarea/storefront/products/_afterpay_pricing.html.haml`](https://github.com/workarea-commerce/workarea-afterpay/blob/v2.1.0/app/views/workarea/storefront/products/_afterpay_pricing.html.haml)


Admin Integration
----------------------------------------------------------------------

Like the Storefront, the Admin shows placed orders and therefore must know how to display tender-specific information for all tender types.
Your tender type may require or benefit from additional Admin integration, but these will be specific to your tender.

The process to integrate your tender type into the Admin therefore looks like this:

1. [Create an _order tender partial_](#order-tender-partial) to handle the display of the new tender type when showing placed orders
2. [Complete other _tender-specific integrations_](#tender-specific-integrations-2) as needed for your tender type


### Order Tender Partial

To properly display placed orders in the Admin, you must provide a partial for your new tender type.

Refer to the following example, and create a similar partial for your specific tender.

[`admin/orders/tenders/_afterpay.html.haml` partial from Workarea Afterpay 2.1.0](https://github.com/workarea-commerce/workarea-afterpay/blob/v2.1.0/app/views/workarea/admin/orders/tenders/_afterpay.html.haml):

```haml
%li= t('workarea.afterpay.tender_description', installment_price: number_to_currency(tender.installment_price), installment_count: Workarea.config.afterpay[:installment_count])
```


### Tender-Specific Integrations

You may need or want more tender-specific integrations with the Admin.
For example, you could allow administrators to search for a specific DeferredPay token, returning the order purchased with that token.

In these cases, work with your retailer and payment service provider to determine what additional work is necessary.
Then refer to concrete examples (e.g. Workarea plugin sources) to see what similar integrations look like.
