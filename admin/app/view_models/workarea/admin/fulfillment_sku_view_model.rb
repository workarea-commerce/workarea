module Workarea
  module Admin
    class FulfillmentSkuViewModel < ApplicationViewModel
      def timeline
        @timeline ||= TimelineViewModel.new(model)
      end

      def tokens
        return [] unless download?
        @tokens ||= Fulfillment::Token.for_sku(id)
      end

      def product
        @product ||=
          begin
            product = Catalog::Product.find_by_sku(model.id)
            ProductViewModel.wrap(product, options) if product.present?
          end
      end
    end
  end
end
