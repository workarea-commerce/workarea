module Workarea
  module Storefront
    class CartViewModel < ApplicationViewModel
      include OrderPricing

      alias_method :order, :model

      # Get a list of cart items the user has added to the order for purchasing.
      # Includes pricing and display data.
      #
      # @return [Array<OrderItemViewModel>]
      #
      def items
        @items ||= model.items.by_newest.reject(&:free_gift?).map do |item|
          CartItemViewModel.new(
            item,
            options.merge(inventory: inventory.for_sku(item.sku))
          )
        end
      end

      # A list of free gift items that are the result of a free item discount.
      # Includes display data. Pricing data is irrelevant for free items.
      #
      # @return [Array<OrderItemViewModel>]
      #
      def free_gifts
        @free_gifts ||= model.items.select(&:free_gift?).select do |item|
          Inventory.any_available?(item.sku)
        end.map do |item|
          OrderItemViewModel.new(item)
        end
      end

      #
      # Shipping
      #
      #

      def shipping_address
        shipping.try(:address)
      end

      def has_shipping_address?
        shipping.try(:address).present?
      end
      alias_method :show_shipping_services?, :has_shipping_address?
      alias_method :show_taxes?, :has_shipping_address?

      def shipping_postal_code
        shipping.try(:address).try(:postal_code)
      end

      def shipping_service
        shipping.try(:shipping_service).try(:name)
      end

      def shipping_options
        return [] unless has_shipping_address?
        @shipping_options ||= Workarea::Checkout::ShippingOptions.new(
          model,
          shipping
        ).available
      end

      def shipping_instructions
        shipping.try(:instructions)
      end

      # Returns recommendations for the cart. The view model it returns behave
      # like {Enumerable}.
      #
      # @return [Workarea::Storefront::CartRecommendationsViewModel]
      #
      def recommendations
        return [] unless model.quantity > 0
        @recommendations ||= CartRecommendationsViewModel.new(model)
      end

      private

      def user
        options[:user]
      end

      def inventory
        @inventory ||= Inventory::Collection.new(model.items.map(&:sku))
      end

      def shipping
        @shipping ||= Shipping.find_by_order(model.id)
      end
    end
  end
end
