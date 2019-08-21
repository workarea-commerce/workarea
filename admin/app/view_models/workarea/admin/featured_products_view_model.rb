module Workarea
  module Admin
    module FeaturedProductsViewModel
      def featured_products
        @featured_products ||=
          begin
            models = Catalog::Product.any_in(id: model.product_ids).to_a

            results = model.product_ids.map do |id|
              tmp = models.detect { |m| m.id == id }
              next unless tmp.present?
              Admin::ProductViewModel.new(tmp)
            end

            results.compact
          end
      end
    end
  end
end
