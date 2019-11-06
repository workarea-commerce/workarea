module Workarea
  module Storefront
    class UserActivityViewModel < ApplicationViewModel
      def products
        @products ||=
          begin
            product_ids = model.viewed.recent_product_ids(max: display_count, unique: true)

            Catalog::Product.find_ordered(product_ids).select(&:active?).map do |product|
              ProductViewModel.wrap(product, options)
            end
          end
      end

      def categories
        @categories ||=
          begin
            category_ids = model.viewed.recent_category_ids(max: display_count, unique: true)
            Catalog::Category.find_ordered(category_ids).select(&:active?)
          end
      end

      private

      def display_count
        Workarea.config.user_activity_display_size
      end
    end
  end
end
