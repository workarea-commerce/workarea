require 'test_helper'

module Workarea
  module Storefront
    class ProductViewModel::SkuOptionsTest < TestCase
      setup :product, :sku_options

      def test_options
        option = ["SKU1 - Color: Red", "SKU1", { data: { sku_option_details: { 'color' => ['Red'] }.to_json } }]
        assert_equal(option, sku_options.to_a.second)
      end

      private

      def product
        @product ||= create_product(
          variants: [
            {
              sku: 'SKU1',
              details: { 'Color' => ['Red'] }
            },
            {
              sku: 'SKU2',
              details: { 'Color' => ['Blue'] }
            }
          ]
        )
      end

      def sku_options
        @sku_options ||= ProductViewModel::SkuOptions.new(product.variants)
      end
    end
  end
end
