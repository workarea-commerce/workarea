# This view model has methods for showing the checkout
# summary partial.
#
# Mostly just sugar methods for making rendering that
# partial easier to understand.
#
module Workarea
  module Storefront
    class Checkout::SummaryViewModel < ApplicationViewModel
      include OrderPricing

      delegate :email, to: :order

      def shippings
        @shippings ||= Storefront::ShippingViewModel.wrap(
          model.shippings,
          options
        )
      end

      # Whether to show the addresses summaries.
      # Based on {Checkout::Steps::Addresses#complete?}
      #
      # @return [Boolean]
      #
      def show_addresses?
        addresses_complete?
      end

      # The current billing address.
      #
      # @return [Address]
      #
      def billing_address
        payment.address || Address.new
      end

      # The current shipping address
      #
      # @return [Shipping::Address]
      #
      def shipping_address
        shipping.try(:address)
      end

      # The current shipping service display name
      #
      # @return [String, nil]
      #
      def shipping_service
        shipping.try(:shipping_service).try(:name)
      end

      # Whether we should show info about shipping address.
      # True as long as the order requires shipping.
      #
      # @return [Boolean]
      #
      def show_shipping_address?
        order.requires_shipping?
      end

      # Whether to show shipping service info in the summary.
      #
      # @return [Boolean]
      #
      def show_shipping_options?
        order.requires_shipping? && shippings.any?(&:show_options?)
      end
      alias_method :shipping_determined?, :show_shipping_options?
      alias_method :show_shipping_service?, :show_shipping_options?

      # Whether the tax total has been determined yet.
      #
      # @return [Boolean]
      #
      def taxes_determined?
        addresses_complete?
      end

      private

      def addresses_complete?
        return @addresses_complete if defined?(@addresses_complete)
        @addresses_complete = Workarea::Checkout::Steps::Addresses.new(self).complete?
      end
    end
  end
end
