module Workarea
  class AddMultipleCartItems
    class Item
      include ActiveModel::Validations

      attr_reader :order, :params, :sku_param, :item

      validate :validate_product
      validate :validate_customizations

      def initialize(order, params)
        @order = order
        @params = params.with_indifferent_access
        @sku_param = @params[:sku]
      end

      def persisted?
        defined?(@item) && @item.persisted?
      end

      def save
        return false unless valid?
        return @item&.persisted? if defined?(@item)

        order.add_item(item_params).tap do |result|
          @item = order.items.find_existing(sku, item_params) if result
        end
      end

      def item_params
        params
          .slice(:product_id, :quantity, :via)
          .merge(sku: sku, customizations: customizations&.to_h || {})
          .merge(item_details)
      end

      def sku
        return unless product.present?
        return @sku if defined?(@sku)

        @sku = product&.skus&.detect { |sku| sku.downcase == sku_param.downcase }
      end

      def product
        return @product if defined?(@product)

        @product =
          if params[:product_id].present?
            Catalog::Product.find(params[:product_id])
          elsif sku_param.present?
           Catalog::Product.find_by_sku(sku_param)
         end
      end

      def customizations
        return unless product.present?
        @customizations ||= Catalog::Customizations.find(product.id, params)
      end

      def item_details
        OrderItemDetails.find!(sku, product_id: product.id).to_h
      end

      private

      def validate_product
        unless product.present? && sku.present?
          errors.add(:base, I18n.t('workarea.add_multiple_cart_items.errors.missing_product'))
        end
      end

      def validate_customizations
        unless !customizations.present? || customizations.valid?
          customizations.errors.full_messages.each { |m| errors.add(:base, m) }
        end
      end
    end
  end
end
