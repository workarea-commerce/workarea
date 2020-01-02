---
title: Implement an Advance Payment Tender Type
excerpt: How to implement an advance payment tender type, including gateway integration, operation implementations, payment model integration, Storefront integration, and Admin integration
created_at: 2019/12/03
---

Implement an Advance Payment Tender Type
======================================================================

Workarea's base platform provides a single advance payment tender type: _store credit_.
However, a retailer may want to offer its customers additional forms of advance payment, such as [Gift Cards](https://github.com/workarea-commerce/workarea-gift-cards/tree/v4.0.0).
To do so, application developers can extend their applications with additional advance payment tender types.

Workarea provides plugins that do this work for you for several payment services.
You should use one of these plugins if you can.
However, there are many such payment services, and a retailer may choose a service for which a Workarea plugin does not yet exist.

In that case, you will need to implement the advance payment tender type yourself, either directly within an application or within a plugin that can be re-used across applications.
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
Replace the pathname `your_engine` with the pathname for your application or plugin, such as `~/discount-supercenter` or `~/workarea-reward-points`.
_
__[2]__
Replace `your_tender_type` and `YourTenderType` with the name of your tender type, for example: `reward_points` and `RewardPoints`.

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

To see a concrete example of a gateway module method, refer to [`Workarea::GiftCards.gateway` from Workarea Gift Cards 4.0.0](https://github.com/workarea-commerce/workarea-gift-cards/blob/v4.0.0/lib/workarea/gift_cards.rb#L7-L9), which relies on a configuration value set by the [`configuration.rb` initializer from Workarea Gift Cards 4.0.0](https://github.com/workarea-commerce/workarea-gift-cards/blob/v4.0.0/config/initializers/configuration.rb#L10).

With Workarea Gift Cards 4.0.0 installed, calling `Workarea::GiftCards.gateway` returns an object of type [`Workarea::GiftCards::Gateway`](https://github.com/workarea-commerce/workarea-gift-cards/blob/v4.0.0/lib/workarea/gift_cards/gateway.rb).

The logic for this gateway module method is simple because the plugin provides its own gateway which uses local documents rather than a service over the network.
The plugin provides a configurable gateway because much of the plugin's functionality could be used with an alternative gateway.


### Proxy Configuration

Workarea Commerce Cloud applications must additionally edit the _proxy configuration_ to allow communication with the payment service over the network.

Use the Workarea CLI to access and edit the proxy configuration.
Add the endpoint(s) for the payment service.
See [CLI, Edit](/cli.html#edit).

(
This step does not apply if your gateway does not communicate with a payment service over the network, like Workarea Gift Cards.
Furthermore, this step may not apply to applications hosted outside of Workarea Commerce Cloud.
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
Replace the pathname `your_engine` with the pathname for your application or plugin, such as `~/discount-supercenter` or `~/workarea-reward-points`.

__[2]__
Replace `your_tender_type_operation` and `YourTenderTypeOperation` with a name matching your tender type, for example: `reward_points_operation` and `RewardPointsOperation`.

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

To see a concrete example of a tender-specific operation mixin, refer to [`Payment::GiftCardOperation` from Workarea Gift Cards 4.0.0](https://github.com/workarea-commerce/workarea-gift-cards/blob/v4.0.0/app/models/workarea/payment/gift_card_operation.rb).

This example doesn't implement exception handling because the gateway class (included with the plugin) defines all exception handling.


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
Rename this module to be specific to your tender type, such as `RewardPointsOperation`.

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

[`Payment::Authorize::GiftCard` from Workarea Gift Cards 4.0.0](https://github.com/workarea-commerce/workarea-gift-cards/blob/v4.0.0/app/models/workarea/payment/authorize/gift_card.rb)


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

[`Payment::Purchase::GiftCard` from Workarea Gift Cards 4.0.0](https://github.com/workarea-commerce/workarea-gift-cards/blob/v4.0.0/app/models/workarea/payment/purchase/gift_card.rb)


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

[`Payment::Capture::GiftCard` from Workarea Gift Cards 4.0.0](https://github.com/workarea-commerce/workarea-gift-cards/blob/v4.0.0/app/models/workarea/payment/capture/gift_card.rb)


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

[`Payment::Refund::GiftCard` from Workarea Gift Cards 4.0.0](https://github.com/workarea-commerce/workarea-gift-cards/blob/v4.0.0/app/models/workarea/payment/refund/gift_card.rb)


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
Also, importantly for an advance payment tender type, this model must implement `#amount=` to disallow assigning an amount greater than the available advance payment (e.g. the gift card balance).

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
    
    def amount=(amount) #[6]
      return super(amount) if amount.blank? || balance >= amount
      super(balance)
    end

    def balance
      gateway.balance(:identifier) || 0.to_m #[7]
    end

    def gateway
      YourTenderType.gateway #[8]
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
Replace the pathname `your_engine` with the pathname for your application or plugin, such as `~/discount-supercenter` or `~/workarea-reward-points`.

__[2]__
Replace `your_tender_type` and `YourTenderType` with the name of your tender type, for example: `reward_points` and `RewardPoints`.

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

__[6]__
Implement `#amount=` to limit the amount that can be assigned.
Do not allow assigning more than the available advance payment (e.g. the gift card balance).

__[7]__
You will likely need to ask the gateway for the available balance.
Implement the appropriate call to the gateway here.

__[8]__
Delegate to the gateway module method you implemented.
Replace `YourTenderType` with the name of your module.
See section [Gateway Module Method](#gateway-module-method).


#### Embedded Tender Model Example

Here is a concrete example of a tender model used in production:

[`Payment::Tender::GiftCard` from Workarea Gift Cards 4.0.0](https://github.com/workarea-commerce/workarea-gift-cards/blob/v4.0.0/app/models/workarea/payment/tender/gift_card.rb)

This example validates and stores a `:number` field and implements `#display_number` to format the number for display.
It uses the API call `Workarea::GiftCards::Gateway#balance` to query the gateway for the available balance.


### Payment Decorator

For each embedded tender, the `Payment` model provides methods to set, clear, and query the presence of a tender of that type.

[Decorate](/articles/decoration.html) the `Payment` model to define the setter, clearer, and query for your embedded tender.


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
      build_your_tender_type unless your_tender_type #[6]
      your_tender_type.attributes = attrs.slice(
        :foo,
        :bar
      )
      save
    end

    def clear_your_tender_type #[7]
      self.your_tender_type = nil
      save
    end

    def your_tender_type? #[8]
      your_tender_type.present?
    end
  end
end
```

__[1]__
Replace the pathname `your_engine` with the pathname for your application or plugin, such as `~/discount-supercenter` or `~/workarea-reward-points`.

__[2]__
If developing an application, you can omit the `with` argument.
If developing a plugin, replace `your_engine` with a slug identifying your plugin, such as `reward_points`.

__[3]__
Replace `:your_tender_type` with a symbol that matches the embedded tender, such as `:reward_points`.
(See [Embedded Tender Model](#embedded-tender-model).)
In some cases, you may want to embed a collection instead of a single object.
For an example, see [Payment Decorator Example](#payment-decorator-example).

__[4]__
Replace `'Workarea::Payment::Tender::YourTenderType'` with the class name of the embedded tender model, such as `'Workarea::Payment::Tender::RewardPoints'`.
(See [Embedded Tender Model](#embedded-tender-model).)

__[5]__
Define a setter for your embedded tender document.
Name the method after your tender type, for example: `set_reward_points`.
If embedding a collection, implement an "adder" instead of a setter.
For an example, see [Payment Decorator Example](#payment-decorator-example).

__[6]__
Build the embedded tender, mutate it as necessary, and save the payment.
Replace the substring `your_tender_type` with the name of your embedded tender, for example: `build_reward_points`.
(This method name relies on meta programming from the Mongoid library).

__[7]__
You should provide this method by convention.
Replace the substring `your_tender_type` with the name of your embedded tender, for example: `clear_reward_points`.

__[8]__
You should provide this method by convention.
Replace the substring `your_tender_type` with the name of your embedded tender, for example: `reward_points?`.


#### Payment Decorator Example

Here is an example of a payment decorator used in production:

[`Payment` decorator from Workarea Gift Cards 4.0.0](https://github.com/workarea-commerce/workarea-gift-cards/blob/v4.0.0/app/models/workarea/payment.decorator)

Workarea Gift Cards embeds a collection of tenders instead of a single tender.
The example therefore uses `embeds_many` instead of `embeds_one` and `add_gift_card` instead of `set_gift_card`.
Additionally, the example validates the size of the embedded collection to ensure it is within the configured limit.


### Tender Types Initializer

The method [`Payment#tenders`](https://github.com/workarea-commerce/workarea/blob/v3.5.0/core/app/models/workarea/payment.rb#L67-L71) returns a collection of all the tenders embedded on that payment.
The tenders in this collection are of different types, and the order in which they appear is the order in which the tenders will be charged/refunded during payment processing.

You must [configure](/articles/configuration.html) `Workarea.config.tender_types` to declare where tenders of your new type should appear within this collection.
All advance payment tenders must be placed _before_ all primary tenders.
The order among advance payment tenders is up to your retailer (e.g. which do they want to apply first: store credit or gift cards?).

As a general rule, plugins for advance payment tender types _prepend_ to the front of the list.
If you are developing within an application, you may want to place the new tender type within the list more precisely.
To create your own initializer, refer to the following boilerplate and example.


#### Tender Types Initializer Boilerplate

Start with the following boilerplate for your initializer.

```ruby
# your_engine/config/initializers/tender_types.rb [1][2]

Workarea.config.tender_types.prepend(:your_tender_type) #[3][4]
```

__[1]__
Replace the pathname `your_engine` with the pathname for your application or plugin, such as `~/discount-supercenter` or `~/workarea-reward-points`.

__[2]__
If desired, change the name of the initializer or add the code that follows to an existing initializer.

__[3]__
Use `#prepend` or any other method of `SwappableList` to insert your tender type into the list.
(See [SwappableList Data Structure](/articles/swappable-list-data-structure.html).)

__[4]__
Replace `:your_tender_type` with the symbolized name of your embedded tender (as implemented on the `Payment` model), such as `:reward_points`.


#### Tender Types Initializer Example

To see a concrete example of this type of initializer, refer to the following:

[`configuration.rb` initializer from Workarea Gift Cards 4.0.0](https://github.com/workarea-commerce/workarea-gift-cards/blob/v4.0.0/config/initializers/configuration.rb#L6)


Storefront Integration
----------------------------------------------------------------------

Workarea's checkout applies some advance payments to orders automatically (e.g. store credit) and allows shoppers to apply additional advance payment types (e.g. gift cards).
The Storefront provides the fields that are necessary for these tender types (e.g. the "add gift card" form).
The Storefront also displays information about each advance payment that's applied to an order, presenting them in a manner similar to order-level discounts (i.e. reductions to the order total).
When the amount of the advance payments covers the entire order, the shopper can complete checkout without providing a primary tender type (e.g. credit card).

You must integrate your new tender type into the Storefront by extending some or all of the following: checkout flow, checkout fields, payment summary data, and the logic to hide/show the primary tender types.
Advance payment tender types vary considerably in their Storefront integrations, but there are a few commonalities.
To integrate your tender type into the Storefront, complete the following:

1. [Extend the _order pricing view models_](#order-pricing-view-models) to provide data about the new tender type for order summaries and checkout display logic
2. [Append _order summary partials_](#order-summary-partials) to display a subtotal for the new tender type within order summaries
3. [Create _order tender partials_](#order-tender-partials) to handle the display of the new tender type when showing placed orders
4. [Complete other _tender specific integrations_](#tender-specific-integrations) as needed for your tender type

Data collected by the _Storefront Integration_ is persisted by the [Payment Model Integration](#payment-model-integration).
These steps therefore overlap.
You will likely need to develop them concurrently.


### Order Pricing View Models

During checkout, Workarea displays order summaries that each include a subtotal for each advance payment tender type (e.g. gift card total).
Also, if the total of _all_ advance payment tenders covers the cost of the order, the shopper does not need to provide a primary tender (e.g. credit card).
The API call to determine this is
[`Storefront::Checkout::PaymentViewModel#order_covered_by_advance_payments?`](https://github.com/workarea-commerce/workarea/blob/v3.5.0/storefront/app/view_models/workarea/storefront/checkout/payment_view_model.rb#L16-L24),
which, in turn, relies on
[`Storefront::OrderPricing#advance_payment_amount`](https://github.com/workarea-commerce/workarea/blob/v3.5.0/storefront/app/view_models/workarea/storefront/order_pricing.rb#L26-L34).

Therefore, for your advance payment tender type, you must implement a method that returns the subtotal for that tender type, and you must extend `#advance_payment_amount` to incorporate that total for your tender type into the amount for all advance payment tenders.  
The latter method is defined in a module that is included in several classes, so Workarea Gift Cards extends all of these classes with its own module, but [decorating](/articles/decoration.html) each of the classes would work equally well.

Review the following examples from [Workarea Gift Cards 4.0.0](https://github.com/workarea-commerce/workarea-gift-cards/tree/v4.0.0), and adapt them to your own implementation:

* [`Storefront::GiftCardOrderPricing#gift_card_amount`](https://github.com/workarea-commerce/workarea-gift-cards/blob/v4.0.0/app/view_models/workarea/storefront/gift_card_order_pricing.rb#L14-L16)
* [`Storefront::GiftCardOrderPricing#advance_payment_amount`](https://github.com/workarea-commerce/workarea-gift-cards/blob/v4.0.0/app/view_models/workarea/storefront/gift_card_order_pricing.rb#L26-L28)
* [`Workarea::GiftCards::Engine`](https://github.com/workarea-commerce/workarea-gift-cards/blob/v4.0.0/lib/workarea/gift_cards/engine.rb#L7-L16) (class extensions)


### Order Summary Partials

Within checkout, the subtotal for each advance payment tender type is displayed within various order summaries.
To include your tender type in these order summaries, you must create and [append](/articles/appending.html) several partials.

Refer to the following examples from [Workarea Gift Cards 4.0.0](https://github.com/workarea-commerce/workarea-gift-cards/tree/v4.0.0), and adapt them to your own implementation:

* Checkout summary:
  * Partial: [`storefront/checkouts/_gift_card_summary.html.haml`](https://github.com/workarea-commerce/workarea-gift-cards/blob/v4.0.0/app/views/workarea/storefront/checkouts/_gift_card_summary.html.haml)
  * Initializer: [`append_points.rb`, 5-8](https://github.com/workarea-commerce/workarea-gift-cards/blob/v4.0.0/config/initializers/append_points.rb#L5-L8)
* Order summary:
  * Partial: [`storefront/orders/_gift_card_summary.html.haml`](https://github.com/workarea-commerce/workarea-gift-cards/blob/v4.0.0/app/views/workarea/storefront/orders/_gift_card_summary.html.haml)
  * Initializer: [`append_points.rb`, 20-23](https://github.com/workarea-commerce/workarea-gift-cards/blob/v4.0.0/config/initializers/append_points.rb#L20-L23)
* Order mailer summary:
  * Partial: [`storefront/order_mailer/_gift_card_summary.html.haml`](https://github.com/workarea-commerce/workarea-gift-cards/blob/v4.0.0/app/views/workarea/storefront/order_mailer/_gift_card_summary.html.haml)
  * Initializer: [`append_points.rb`, 25-28](https://github.com/workarea-commerce/workarea-gift-cards/blob/v4.0.0/config/initializers/append_points.rb#L25-L28)


### Order Tender Partials

When showing placed orders in the Storefront, Workarea needs to know how to display information about tenders of your new type.
This information includes the type of tender, the amount, and tender-specific details such as the number of installments or a gift card number.
When displaying this information, Workarea automatically looks for specific partials to render.

You must create these partials for your tender type.
Refer to the following examples, and create corresponding partials for your tender type implementation.

[`storefront/orders/tenders/_gift_card.html.haml` partial from Workarea Gift Cards 4.0.0](https://github.com/workarea-commerce/workarea-gift-cards/blob/v4.0.0/app/views/workarea/storefront/orders/tenders/_gift_card.html.haml):

```haml
.data-card
  .data-card__cell
    %p.data-card__line.data-card__credit-card
      = inline_svg('workarea/storefront/payment_icons/gift_card.svg', title: t('workarea.storefront.orders.tenders.gift_card.title'), class: 'payment-icon')
      %span.data-card__credit-card-number
        = t('workarea.storefront.credit_cards.summary', issuer: t('workarea.storefront.orders.tenders.gift_card.title'), number: tender.display_number)
    %p.data-card__line
      %strong
        #{t('workarea.storefront.orders.amount')}: #{number_to_currency tender.amount}
```

[`storefront/order_mailer/tenders/_gift_card.html.haml` partial from Workarea Gift Cards 4.0.0](https://github.com/workarea-commerce/workarea-gift-cards/blob/v4.0.0/app/views/workarea/storefront/order_mailer/tenders/_gift_card.html.haml):

```haml
%p
  = t('workarea.storefront.gift_cards.gift_card')
  %br
  #{tender.display_number}:
  = number_to_currency(tender.amount)
```


### Tender-Specific Integrations

Your Storefront integration will likely require more&mdash;possibly much more&mdash;than the preceding steps, but the remaining work will be specific to your tender type and difficult to outline here as a general procedure.
You may need to implement Storefront routes, controllers, views, view models, helpers, assets, libraries, configuration, translations, and tests to complete your integration.
Many integrations require fields for collecting tender-specific data, such as a gift card number, and require corresponding changes to the checkout flow.

Work with your retailer and payment service provider to determine what additional work is necessary.
Then refer to concrete examples (e.g. Workarea plugin sources) to see what similar integrations look like.

For an example, review the following files, which are the more significant aspects of the [Workarea Gift Cards 4.0.0](https://github.com/workarea-commerce/workarea-gift-cards/tree/v4.0.0) Storefront integration:

* [`config/routes.rb`](https://github.com/workarea-commerce/workarea-gift-cards/blob/v4.0.0/config/routes.rb)
* [`app/controllers/workarea/storefront/checkout/gift_cards_controller.rb`](https://github.com/workarea-commerce/workarea-gift-cards/blob/v4.0.0/app/controllers/workarea/storefront/checkout/gift_cards_controller.rb)
* [`app/models/workarea/checkout/steps/gift_card.rb`](https://github.com/workarea-commerce/workarea-gift-cards/blob/v4.0.0/app/models/workarea/checkout/steps/gift_card.rb)
* [`app/views/workarea/storefront/checkouts/_gift_card_payment.html.haml`](https://github.com/workarea-commerce/workarea-gift-cards/blob/v4.0.0/app/views/workarea/storefront/checkouts/_gift_card_payment.html.haml)
* [`app/views/workarea/storefront/checkouts/_gift_card_error.html.haml`](https://github.com/workarea-commerce/workarea-gift-cards/blob/v4.0.0/app/views/workarea/storefront/checkouts/_gift_card_error.html.haml)
* [`config/initializers/append_points.rb`](https://github.com/workarea-commerce/workarea-gift-cards/blob/v4.0.0/config/initializers/append_points.rb)


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

[`admin/orders/tenders/_gift_card.html.haml` partial from Workarea Gift Cards 4.0.0](https://github.com/workarea-commerce/workarea-gift-cards/blob/v4.0.0/app/views/workarea/admin/orders/tenders/_gift_card.html.haml):

```haml
%li
  = inline_svg('workarea/admin/payment_icons/gift_card.svg', title: t('workarea.admin.orders.tenders.gift_card.title'), class: 'payment-icon')
  = t('workarea.admin.orders.tenders.gift_card.title')
  = tender.display_number
  = number_to_currency tender.amount
```


### Tender-Specific Integrations

You may need or want more tender-specific integrations with the Admin.
For example, you could allow administrators to search for a gift card number, returning the order purchased with that card.

In these cases, work with your retailer and payment service provider to determine what additional work is necessary.
Then refer to concrete examples (e.g. Workarea plugin sources) to see what similar integrations look like.
