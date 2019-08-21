require 'test_helper'

module Workarea
  module Storefront
    class ProductsPerformanceTest < Workarea::PerformanceTest
      setup :setup_product

      def setup_product
        @product = create_complex_product
        3.times { create_category(product_ids: [@product.id]) }
      end

      def test_high_variant_count
        get storefront.product_path(@product)
        assert(response.ok?)
      end
    end
  end
end
