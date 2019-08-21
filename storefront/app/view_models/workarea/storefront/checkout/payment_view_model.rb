module Workarea
  module Storefront
    class Checkout::PaymentViewModel < ApplicationViewModel
      include CheckoutContent
      include OrderPricing

      # Can the current store credit cover the entire order
      # total? Used for rendering store credit messaging.
      #
      # @return [Boolean]
      #
      def order_covered_by_store_credit?
        store_credit_balance >= order.total_price
      end

      # Can advance payments (store credit, gift cards) cover the cost of the
      # entire order? Used for hiding primary payments (e.g. credit cards) when
      # not necessary to complete the order.
      #
      # @return [Boolean]
      #
      def order_covered_by_advance_payments?
        advance_payment_amount >= order.total_price
      end

      # Is another tender required? Used for rendering
      # payment messaging.
      #
      # @return [Boolean]
      #
      def tender_required?
        order_balance > 0
      end

      # Whether the current payment is set to credit card.
      # Used to determine whether to output credit card errors.
      #
      # @return [Boolean]
      #
      def credit_card?
        !!payment.credit_card
      end

      # The {Payment::SavedCreditCard#id} for the current
      # payment.
      #
      # @return [String, nil]
      #
      def saved_card_id
        payment.saved_card_id
      end

      # The credit card tender for the payment.
      # Used for outputting errors and form fields.
      #
      # @return [Payment::Tender::CreditCard, nil]
      #
      def credit_card
        payment.credit_card
      end

      # The list of saved credit cards from the current {Payment}.
      # Returns an empty list if user or email are blank.
      #
      # @return [Array<CreditCardViewModel>]
      #
      def credit_cards
        @credit_cards ||= if user.blank? || order.email.blank?
                            []
                          else
                            payment.saved_credit_cards.map do |card|
                              CreditCardViewModel.new(
                                card,
                                selected: selected_payment_id
                              )
                            end
                          end
      end

      # Whether this checkout should be using a new credit card.
      # Used to determine whether the new credit card radio button
      # should be checked.
      #
      # @return [Boolean]
      #
      def using_new_card?
        tender_required? && !credit_cards.any?(&:selected?)
      end

      private

      def selected_payment_id
        if credit_card? && credit_card.saved_card_id.present?
          credit_card.saved_card_id
        elsif options[:payment].present?
          options[:payment]
        else
          payment.try(:default_credit_card).try(:id)
        end
      end
    end
  end
end
