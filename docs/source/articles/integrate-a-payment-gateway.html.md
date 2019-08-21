---
title: Integrate a Payment Gateway
excerpt: Workarea uses the ActiveMerchant gem for integration with payment gateways. This gem consolidates gateway functionalities under a common interface.
---

# Integrate a Payment Gateway

Workarea uses the ActiveMerchant gem for integration with payment gateways. This gem consolidates gateway functionalities under a common interface.

**Note:** Different gateways offer different functionality under different names!

Because of the variance in payment gateways, you will probably need to tailor your installation to the gateway. Fortunately, Workarea consolidates gateway knowledge into the `Workarea::Payment::StoreCreditCard` class. This class is responsible for representing a credit card on the gateway. On that class is a single method the system uses to save it on the gateway (get a token to use to reference the card from now on).

**Note:** The Workarea platform out-of-the-box requires a gateway that supports tokenization! This is done for security. Please ensure your gateway supports this functionality.

Here is the out of the box implementation of saving the card on the gateway, presented for reference. The `#save!` method is called when the system needs to persist a credit card to be referenced later.

workarea-core/app/models/workarea/payment/store\_credit\_card.rb :

```
module Workarea
  class Payment
    class StoreCreditCard
      include CreditCardOperation

      def initialize(credit_card, options = {})
        @credit_card = credit_card
        @options = options
      end

      def perform!
        return true if @credit_card.token.present?

        response = handle_active_merchant_errors do
          gateway.store(@credit_card.to_active_merchant)
        end

        @credit_card.token = response.params['billingid']
      end

      def save!
        perform!
        @credit_card.save
      end
    end
  end
end
```

Error handling for all communication to the gateway is consolidated within a single module, and then included for all operations to ensure consistent handling of possible errors. You see this in action with the call to `#handle_active_merchant_errors` above. The full implmentation is below for reference.

workarea-core/app/models/workarea/payment/credit\_card\_operation.rb :

```
module Workarea
  class Payment
    module CreditCardOperation
      def handle_active_merchant_errors
        begin
          yield
        rescue ActiveMerchant::ResponseError => error
          error.response
        rescue ActiveMerchant::ActiveMerchantError,
                ActiveMerchant::ConnectionError => error
          ActiveMerchant::Billing::Response.new(false, nil)
        end
      end

      def gateway
        Workarea.config.gateways.credit_card
      end
    end
  end
end
```

After customizing these classes, you may need to customize how this token is used with the gateway. There are a number of places for this:

- `Workarea::Payment::Authorize::CreditCard`
- `Workarea::Payment::Capture::CreditCard`
- `Workarea::Payment::Purchase::CreditCard`
- `Workarea::Payment::Refund::CreditCard`

Each of these responds to the `#complete!` method, which should implement performing the respective operation on the gateway. Out of the box implementation for purchase:

workarea-core/app/models/workarea/purchase/credit\_card.rb :

```
module Workarea
  class Payment
    module Purchase
      class CreditCard
        include OperationImplementation
        include CreditCardOperation

        def complete!
          # Some gateways will tokenize in the same request as the auth/capture.
          # If that is the case for the gateway you are implementing, omit the
          # following line, and save the token on the tender after doing the
          # gateway authorization.
          return unless StoreCreditCard.new(tender, options).save!

          transaction.response = handle_active_merchant_errors do
            gateway.purchase(
              transaction.amount.cents,
              tender.to_active_merchant
            )
          end
        end

        def cancel!
          return unless transaction.success?

          transaction.cancellation = handle_active_merchant_errors do
            gateway.void(transaction.response.params['authorization'])
          end
        end
      end
    end
  end
end
```


