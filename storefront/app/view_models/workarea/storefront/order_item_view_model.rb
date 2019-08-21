module Workarea
  module Storefront
    class OrderItemViewModel < ApplicationViewModel
      #
      # Catalog details
      #
      #

      def product
        @product ||= ProductViewModel.wrap(catalog_product, sku: sku)
      end

      def image
        product.primary_image
      end

      def details
        @details ||=
          begin
            tmp = variant.details.map do |k, v|
              [k.to_s.titleize, [v].flatten.join(', ')]
            end

            Hash[tmp]
          end
      end

      def product_name
        product.name
      end

      def sku_name
        variant.name
      end

      def has_options?
        product.sku_options.length > 1
      end

      def catalog_product
        @catalog_product ||= if product_attributes.present?
                               Mongoid::Factory.from_db(Catalog::Product, product_attributes)
                             else
                               Catalog::Product.find_by_sku(sku)
                             end
      end

      #
      # Pricing
      #
      #

      def multiple?
        quantity > 1
      end

      def original_price
        price_adjustments.first.data['original_price'].to_m
      end

      def customizations_unit_price
        (price_adjustments.detect do |adjustment|
          adjustment.description =~ /customizations/i
        end.try(:unit) || 0).to_m
      end

      def total_adjustments
        @total_adjustments ||= price_adjustments.reduce_by_description('item')
      end

      #
      # Fulfillment
      #
      #
      def fulfillment_sku
        @fulfillment_sku ||=
          Fulfillment::Sku.find_or_initialize_by(id: model.sku)
      end

      def token
        return unless fulfillment_sku.download?
        @token ||= Fulfillment::Token.for_order_item(model.order.id, model.id)
      end

      def default_category_name
        @default_category_name =
          Categorization.new(catalog_product).default_model.try(:name)
      end

      def variant
        catalog_product.variants.detect do |variant|
          variant.sku.downcase == model.sku.downcase
        end
      end
    end
  end
end
