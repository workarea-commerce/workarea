module Workarea
  module Admin
    class PricingSkuViewModel < ApplicationViewModel
      def timeline
        @timeline ||= TimelineViewModel.new(model)
      end

      def product
        @product ||=
          begin
            product = Catalog::Product.find_by_sku(model.id)
            ProductViewModel.wrap(product, options) if product.present?
          end
      end

      def inventory
        @inventory ||= Inventory::Sku.where(id: model.id).first
      end

      # All prices that this SKU will be sold at. Makes a determination
      # based on whether the price is on sale.
      #
      # @return [Array<Workarea::Pricing::Price>]
      def sell_prices
        prices.sort_by(&:sell)
      end

      # The lowest price that this SKU can be purchased for. Dependent
      # on the current sale state of the SKU.
      #
      # @return [Money]
      def min_price
        sell_prices.first&.sell
      end

      # The highest regular price set on this SKU.
      #
      # @return [Money]
      def max_price
        sell_prices.last&.sell
      end

      # Show a price range if the `min_price` and `max_price` are not
      # the same value.
      #
      # @return [Boolean]
      def show_range?
        min_price.present? && max_price.present? && min_price != max_price
      end

      # This SKU is considered "on sale" if it is marked as such, or if
      # any prices that it contains are marked as such.
      #
      # @return [Boolean]
      def on_sale?
        model.on_sale? || prices.any?(&:on_sale?)
      end

      # The price of this SKU as rendered on the index page. Shows a
      # price range when multiple prices are contained within the SKU,
      # otherwise it just shows the only sell price available.
      #
      # @return [String]
      def sell_price
        return if min_price.blank?
        return min_price.format unless show_range?

        "#{max_price.format} – #{min_price.format}"
      end
    end
  end
end
