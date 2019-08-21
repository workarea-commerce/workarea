module Workarea
  class Payment
    class StoreCreditCard
      include CreditCardOperation

      def initialize(credit_card, options = {})
        @credit_card = credit_card
        @options = options
      end

      # Reaches out to the credit card gateway to store a new credit card
      #
      # @return [Boolean] the result of the gateway call
      def perform!
        return true if @credit_card.token.present?

        response = handle_active_merchant_errors do
          gateway.store(@credit_card.to_active_merchant)
        end

        @credit_card.token = response.params['billingid']

        response.success?
      end

      # Reaches out to the credit card gateway to store a new credit card
      #
      # @return [Boolean] the result of the gateway call and saving to the db
      def save!
        perform! && @credit_card.save
      end
    end
  end
end
