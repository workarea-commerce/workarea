module Workarea
  module Storefront
    class RecommendationsViewModel < ApplicationViewModel
      include Enumerable
      delegate :each, :size, :length, to: :products

      def products
        @products ||=
          begin
            results = find_displayable_products(product_ids)

            if results.size < result_count
              results.push(*find_displayable_products(popular_product_ids))
            end

            ProductViewModel.wrap(results.uniq).take(result_count)
          end
      end

      def popular_product_ids
        Insights::TopProducts
          .current
          .results
          .map { |r| r['product_id'] }
          .take(result_count)
      end

      def product_ids
        raise NotImplementedError
      end

      def result_count
        raise NotImplementedError
      end

      private

      def find_displayable_products(ids)
        Catalog::Product.find_ordered(ids).select(&:active?).select(&:purchasable?)
      end
    end
  end
end
