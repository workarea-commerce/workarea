module Workarea
  module Pricing
    class CacheKey
      attr_reader :shippings
      attr_accessor :order
      delegate :pricing, :discounts, to: :@request

      def initialize(order, shippings, request)
        @order = order
        @shippings = shippings
        @request = request
      end

      def parts
        [
          pricing_key,
          discount_key,
          order_key,
          shipping_service_key,
          tax_key
        ]
      end

      def to_s
        Digest::SHA1.hexdigest(parts.join('/'))
      end

      private

      def pricing_key
        pricing.map(&:cache_key).join
      end

      def discount_key
        discounts.map(&:cache_key).join
      end

      def order_key
        order.cache_key
      end

      def shipping_service_key
        shippings.map(&:cache_key).join
      end

      def tax_key
        Workarea::Tax::Category.all.map(&:cache_key).join
      end
    end
  end
end
