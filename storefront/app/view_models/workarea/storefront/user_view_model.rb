module Workarea
  class Storefront::UserViewModel < ApplicationViewModel
    delegate :display_number, :month, :year,
             to: :default_credit_card, prefix: true

    def has_default_addresses?
      addresses.present?
    end

    def default_credit_card
      @default_credit_card ||= payment.default_credit_card
    end

    def has_credit_card?
      !!default_credit_card
    end

    def credit_cards
      payment.credit_cards
    end

    def recent_orders
      @recent_orders ||= recent_order_models.map do |order|
        Storefront::OrderViewModel.new(
          order,
          fulfillment_status: fulfillment_statuses[order.id]
        )
      end
    end

    def email_signup?
      return @email_signup if defined?(@email_signup)
      @email_signup = Email.signed_up?(email)
    end

    private

    def recent_order_models
      @recent_order_models ||= Order.recent(
        model.id,
        Workarea.config.recent_order_count
      )
    end

    def fulfillment_statuses
      @fulfillment_statuses ||= Fulfillment.find_statuses(
        *recent_order_models.map(&:id)
      )
    end

    def payment
      @payment ||= Payment::Profile.lookup(PaymentReference.new(model))
    end
  end
end
