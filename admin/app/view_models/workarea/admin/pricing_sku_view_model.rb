module Workarea
  module Admin
    class PricingSkuViewModel < ApplicationViewModel
      def timeline
        @timeline ||= TimelineViewModel.new(model)
      end

      def product
        @product ||=
          begin
            product = Catalog::Product.find_by_sku(model.id)
            ProductViewModel.wrap(product, options) if product.present?
          end
      end

      def inventory
        @inventory ||= Inventory::Sku.where(id: model.id).first
      end
    end
  end
end
