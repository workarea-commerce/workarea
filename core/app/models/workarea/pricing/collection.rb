module Workarea
  module Pricing
    class Collection
      include Enumerable
      attr_reader :skus
      delegate :any?, :empty?, :each, to: :records

      def initialize(skus, records = nil)
        @skus = Array(skus)
        @records = records
      end

      def for_sku(sku, options = {})
        sku = records.detect { |r| r.id == sku } || Sku.new(id: sku)
        sku.find_price(options)
      end

      def all_selling_prices
        return @all_selling_prices if defined?(@all_selling_prices)
        @all_selling_prices = generic_prices.map(&:sell).compact
      end

      def regular_min_price
        return @regular_min_price if defined?(@regular_min_price)
        @regular_min_price = generic_prices.map(&:regular).sort.first
      end

      def regular_max_price
        return @regular_max_price if defined?(@regular_max_price)
        @regular_max_price = generic_prices.map(&:regular).sort.last
      end

      def sale_min_price
        return @sale_min_price if defined?(@sale_min_price)
        @sale_min_price = generic_prices.map(&:sale).compact.sort.first
      end

      def sale_max_price
        return @sale_max_price if defined?(@sale_max_price)
        @sale_max_price = generic_prices.map(&:sale).compact.sort.last
      end

      def sell_min_price
        return @sell_min_price if defined?(@sell_min_price)
        @sell_min_price = generic_prices.map(&:sell).sort.first
      end

      def sell_max_price
        return @sell_max_price if defined?(@sell_max_price)
        @sell_max_price = generic_prices.map(&:sell).sort.last
      end

      def msrp_min_price
        return @msrp_min_price if defined?(@msrp_min_price)
        @msrp_min_price = records.map(&:msrp).compact.sort.first
      end

      def msrp_max_price
        return @msrp_max_price if defined?(@msrp_max_price)
        @msrp_max_price = records.map(&:msrp).compact.sort.last
      end

      def on_sale?
        return !!@on_sale if defined?(@on_sale)
        @on_sale = generic_prices.any?(&:on_sale?)
      end

      def has_prices?
        return !!@has_prices if defined?(@has_prices)
        @has_prices = generic_prices.any?
      end

      def records
        @records ||= Sku.where(:_id.in => skus).to_a
      end

      private

      def generic_prices
        @generic_prices ||= records.map(&:prices).flatten.select(&:generic?)
      end
    end
  end
end
