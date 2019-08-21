# This class represents the valid shipping options for an order
# before that order has been placed. Looks up pricing/discounts
# data to ensure accurate shipping info for display.
#
# Used by cart/checkout view models and Checkout classes for
# selecting and updating a valid shipping service.
#
module Workarea
  class Checkout::ShippingOptions
    attr_reader :order, :shipping

    def initialize(order, shipping)
      @order = order
      @shipping = shipping
    end

    # All available and valid shipping services for this order.
    # Includes the discounts on the shipping options.
    #
    # @return [Array<ShippingOption>]
    #
    def available
      @available ||= all_options.each do |option|
        option.price_adjustments = price_adjustments[option.name] || []
      end
    end

    # Find a valid shipping option against this shipping service.
    # Defaults to the first to ensure no blank shipping service
    # ends up set on an order. Will return nil if no available
    # and valid shipping option.
    #
    # @return [ShippingOption, nil]
    #
    def find_valid(name)
      available.detect { |o| o.name == name } || available.first
    end

    # Checks whether the currently selected shipping service and its pricing are
    # valid. Used when placing order to determine if the current state is good
    # to go.
    #
    # Sets a validation message on the shipping when the result is false so the
    # user is told.
    #
    # @return [Boolean]
    #
    def valid?
      return false if shipping.blank? || shipping.shipping_service.blank?

      current_shipping_option = all_options.detect do |shipping_option|
        shipping_option.carrier == shipping.shipping_service.carrier &&
          shipping_option.name == shipping.shipping_service.name &&
          shipping_option.service_code == shipping.shipping_service.service_code
      end

      result = shipping.shipping_service.present? &&
                current_shipping_option.present? &&
                current_shipping_option.base_price == shipping.base_price

      unless result
        shipping.errors.add(
          :shipping_service,
          I18n.t('workarea.errors.messages.must_be_updated')
        )
      end

      result
    end

    private

    def all_options
      @all_options ||=
        begin
          packaging = Packaging.new(order, shipping)
          shipping.find_method_options(packaging.packages)
        end
    end

    def price_adjustments
      @price_adjustments ||=
        begin
          all_options.inject({}) do |memo, option|
            test_order = order.clone
            test_shipping = shipping.clone
            test_shipping.apply_shipping_service(option.to_h)

            price_adjustments = Pricing.find_shipping_discounts(
              test_order,
              test_shipping
            )

            memo.merge!(option.name => price_adjustments)
          end
        end
    end
  end
end
