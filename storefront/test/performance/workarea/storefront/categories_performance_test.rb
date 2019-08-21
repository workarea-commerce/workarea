require 'test_helper'

module Workarea
  module Storefront
    class CategoriesPerformanceTest < Workarea::PerformanceTest

      setup :setup_category

      def setup_category
        Sidekiq::Callbacks.disable do
          @products = Array.new(Workarea.config.per_page) do
            create_complex_product
          end
        end

        BulkIndexProducts.perform_by_models(@products)
        @category = create_category(product_ids: @products.map(&:id))
      end

      def test_categories_with_complex_products
        get storefront.category_path(@category)
        assert(response.ok?)
      end
    end
  end
end
