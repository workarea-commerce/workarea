# This class is responsible for consolidating
# auto completion data for a given checkout. It's
# params method is passed to {Checkout#update} to complete
# as much of checkout as possible.
#
module Workarea
  class Checkout::AutoComplete
    attr_reader :order, :payment, :user

    def initialize(order, payment, user)
      @order = order
      @payment = payment
      @user = user
    end

    # The params for the most autocomplete info that is
    # present for the current user. Passed to {Checkout#update}
    # to autocomplete the order.
    #
    # @return [Hash]
    #
    def params
      result = {
        email: user.email,
        payment: credit_card.try(:id)
      }

      if billing_address.present?
        result[:billing_address] = billing_address.attributes.slice(
            *address_attr_keys
          )
      end

      if shipping_address.present?
        result[:shipping_address] = shipping_address.attributes.slice(
            *address_attr_keys
          )
      end

      result
    end

    # The billing address used to autocomplete the checkout.
    #
    # @return [Address, nil]
    #
    def billing_address
      user.default_billing_address
    end


    # The shipping address used to autocomplete the checkout.
    #
    # @return [Address, nil]
    #
    def shipping_address
      user.default_shipping_address
    end

    # The credit card used to autocomplete the checkout.
    #
    # @return [Payment::SavedCreditCard, nil]
    #
    def credit_card
      payment.default_credit_card
    end

    private

    def address_attr_keys
      Workarea.config.address_attributes.map(&:to_s)
    end
  end
end
