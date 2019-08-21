module Workarea
  module Admin
    class RecommendationsViewModel < ApplicationViewModel
      def sources_display
        t('workarea.admin.recommendations.sources')
      end

      def products
        @products ||=
          begin
            models = Catalog::Product.any_in(id: product_ids).to_a

            product_ids.map do |id|
              model = models.detect { |m| m.id == id }
              next unless model

              ProductViewModel.new(model)
            end.compact
          end
      end
    end
  end
end
