module Workarea
  module Pricing
    class Sku
      class MissingPrices < RuntimeError; end

      include ApplicationDocument
      include Releasable
      include UnsupportedSegmentation

      field :_id, type: String
      field :on_sale, type: Boolean, default: false
      field :discountable, type: Boolean, default: true
      field :tax_code, type: String
      field :msrp, type: Money

      embeds_many :prices, class_name: 'Workarea::Pricing::Price'

      validate :default_min_quantity

      def self.sorts
        [Sort.modified, Sort.sku, Sort.newest]
      end

      # This is for compatibility with the admin, all models must implement this
      #
      # @return [String]
      #
      def name
        I18n.t('workarea.pricing_sku.name', id: id)
      end

      # Find the price to sell at for a specific options.
      #
      # The only supported option is :quantity, but this takes an options hash
      # as an extension point to plugins and implementations.
      #
      # @param [Hash]
      # @return [Pricing::Price]
      #
      def find_price(options = {})
        quantity = options[:quantity] || 1

        match = active_prices.detect do |price|
          quantity >= price.min_quantity
        end

        match || Price.new
      end

      # Default selling price, when one unit is placed
      # into the cart of an anonymous user.
      #
      # @return [Money]
      #
      def sell_price
        find_price(quantity: 1).sell
      end
      alias_method :regular_price, :sell_price

      # Default sale price, when one unit is placed
      # into the cart of an anonymous user.
      #
      # @return [Money]
      #
      def sale_price
        find_price(quantity: 1).sale
      end

      # All active prices (with i18n fallbacks included) for the given
      # SKU.
      #
      # @return [Array<Workarea::Pricing::Price>]
      def active_prices
        prices.select(&:active).sort_by(&:min_quantity).reverse
      end

      private

      def default_min_quantity
        if prices.one? && prices.first.min_quantity != 1
          errors.add(
            :base,
            I18n.t('workarea.errors.messages.quantity_one_first_price')
          )
        end
      end
    end
  end
end
