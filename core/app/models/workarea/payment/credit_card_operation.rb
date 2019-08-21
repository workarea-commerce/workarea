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
