module Workarea
  module Storefront
    class RecommendationsViewModel < ApplicationViewModel
      include Enumerable
      delegate :each, :size, :length, to: :products

      def products
        @products ||=
          begin
            results = Catalog::Product.active.purchasable.find_ordered(product_ids)

            if results.size < result_count
              results.push(
                *Catalog::Product.active.purchasable.find_ordered(popular_product_ids)
              )
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
    end
  end
end
