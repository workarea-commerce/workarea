module Workarea
  module Admin
    module FeaturedProductsViewModel
      def featured_products
        @featured_products ||= Catalog::Product.find_ordered(model.product_ids).map do |product|
          Admin::ProductViewModel.wrap(
            product,
            inventory: Inventory::Collection.new(product.skus)
          )
        end
      end
    end
  end
end
