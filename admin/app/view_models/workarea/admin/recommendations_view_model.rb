module Workarea
  module Admin
    class RecommendationsViewModel < ApplicationViewModel
      def sources_display
        t('workarea.admin.recommendations.sources')
      end

      def products
        @products ||= Catalog::Product.find_ordered(product_ids).map do |product|
          ProductViewModel.wrap(product)
        end
      end
    end
  end
end
