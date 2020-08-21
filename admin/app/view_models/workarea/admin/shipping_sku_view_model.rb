module Workarea
  module Admin
    class ShippingSkuViewModel < ApplicationViewModel
      def weight
        I18n.t("workarea.admin.shipping_skus.unit.#{weight_units}", count: model.weight || 0)
      end

      def height
        I18n.t("workarea.admin.shipping_skus.unit.#{length_units}", count: model.height || 0)
      end

      def width
        I18n.t("workarea.admin.shipping_skus.unit.#{length_units}", count: model.width || 0)
      end

      def length
        I18n.t("workarea.admin.shipping_skus.unit.#{length_units}", count: model.length || 0)
      end

      def timeline
        @timeline ||= TimelineViewModel.new(model)
      end

      def product
        return @product if defined?(@product)

        @product = begin
          product = Catalog::Product.find_by_sku(model.id)
          ProductViewModel.wrap(product, options) if product.present?
        end
      end
    end
  end
end
