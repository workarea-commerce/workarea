require 'test_helper'

module Workarea
  module Pricing
    class CacheKeyTest < TestCase
      setup :setup_tax_category,
            :setup_discount,
            :setup_product,
            :setup_order,
            :setup_order_item,
            :setup_shipping,
            :setup_pricing,
            :setup_payment,
            :setup_cache_key

      def test_parts
        parts = @cache_key.parts.flatten

        assert_includes(parts, @pricing.cache_key)
        assert_includes(parts, @payment.cache_key)
        assert_includes(parts, @discount.reload.cache_key)
        assert_includes(parts, @order.cache_key)
        assert_includes(parts, @shipping.cache_key)
        assert_includes(parts, @tax.reload.cache_key)
      end

      def test_to_s
        digest = Digest::SHA1.hexdigest(@cache_key.parts.join('/'))
        assert_equal(@cache_key.to_s, digest)
      end

      private

      def setup_tax_category
        @tax = create_tax_category
      end

      def setup_discount
        @discount = create_order_total_discount(order_total: 1.to_m)
      end

      def setup_order
        @order = create_order
      end

      def setup_order_item
        @order.add_item(sku: @sku, product_id: @product.id)
      end

      def setup_product
        @product = create_product
        @sku = @product.skus.first
      end

      def setup_shipping
        @shipping = create_shipping
      end

      def setup_pricing
        @pricing = Pricing::Sku.find(@sku)
        @request = Request.new(@order, @shipping)
      end

      def setup_payment
        @payment = create_payment(id: @order.id)
      end

      def setup_cache_key
        @cache_key = CacheKey.new(@order, [@shipping], @payment, @request)
      end
    end
  end
end
