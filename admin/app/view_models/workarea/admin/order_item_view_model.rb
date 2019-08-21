module Workarea
  module Admin
    class OrderItemViewModel < ApplicationViewModel
      def product
        @product ||= ProductViewModel.wrap(catalog_product, sku: sku)
      end

      def image
        product.primary_image
      end

      def catalog_product
        @catalog_product ||= if product_attributes.present?
                               Mongoid::Factory.from_db(Catalog::Product, product_attributes)
                             else
                               Catalog::Product.find_by_sku(sku)
                             end
      end

      def variant
        product.variants.where(sku: sku).first
      end

      def categories
        @categories ||= Categorization.new(catalog_product).to_models
      end
    end
  end
end
