module Workarea
  class Checkout
    module Steps
      class Payment < Base
        # Update the payment step of checkout (does not place the order).
        # Clears the previous credit card because we may not need one anymore
        # and we shouldn't keep one if we don't need it.
        #
        # Processes the payment params to determine whether it's a saved card
        # or new card.
        #
        # @param [Hash] params
        # @option params [String] :payment The payment option, either new_card or UUID of saved card
        # @option params [String] :credit_card New card attributes
        #
        # @return [Boolean] whether the update succeeded (order and payment were saved)
        #
        def update(params = {})
          return false unless payment.address.present?

          set_payment_profile
          set_credit_card(params)
          update_order_pricing
          update_payment_tenders

          persist_update
        end

        # Whether this checkout step is finished.
        # Requires:
        # * order to be purchasable
        # * payment purchasable for order total_price
        #
        # @return [Boolean]
        #
        def complete?
          order.purchasable? && payment.purchasable?(order.total_price)
        end

        private

        def set_payment_profile
          payment.set(profile_id: payment_profile.try(:id))
        end

        def set_credit_card(params)
          payment.clear_credit_card
          card_params = Checkout::CreditCardParams.new(params)

          if card_params.new? && card_params.number.present?
            payment.set_credit_card(card_params.new_card)
          elsif card_params.saved?
            payment.set_credit_card(saved_card_id: card_params.saved_card_id)
          end
        end

        def update_order_pricing
          Pricing.perform(order, shippings)
        end

        def update_payment_tenders
          payment.adjust_tender_amounts(order.total_price)
        end

        def persist_update
          order.save && payment.save
        end
      end
    end
  end
end
