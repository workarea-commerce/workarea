module Workarea
  module Storefront
    class UserActivityViewModel < ApplicationViewModel
      def products
        @products ||=
          begin
            product_ids = model.product_ids.uniq.first(display_count)
            models = Catalog::Product.any_in(_id: product_ids).to_a
            models = models.select(&:active?)

            product_ids.map do |id|
              product = models.detect { |p| p.id == id }
              ProductViewModel.wrap(product) if product
            end.compact
          end
      end

      def categories
        @categories ||=
          begin
            category_ids = model.category_ids.uniq.first(display_count)
            models = Catalog::Category.any_in(_id: category_ids).to_a

            category_ids.map do |id|
              models.detect { |c| c.id.to_s == id.to_s }
            end.compact
          end
      end

      def searches
        model.searches.uniq.first(display_count)
      end

      private

      def display_count
        Workarea.config.user_activity_display_size
      end
    end
  end
end
