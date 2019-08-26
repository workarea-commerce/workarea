module Workarea
  module Pricing
    class Override
      include ApplicationDocument

      # This will be the order id
      field :_id, type: String, default: -> { BSON::ObjectId.new.to_s }
      field :created_by_id, type: String
      field :subtotal_adjustment, type: Money, default: 0
      field :shipping_adjustment, type: Money, default: 0
      field :item_prices, type: Hash, default: {}

      def has_adjustments?
        adjusts_shipping? || adjusts_subtotal? || adjusts_items?
      end

      def adjusts_shipping?
        shipping_adjustment.present? && !shipping_adjustment.zero?
      end

      def adjusts_subtotal?
        subtotal_adjustment.present? && !subtotal_adjustment.zero?
      end

      def adjusts_items?
        item_prices.present? &&
          item_prices.values.reject(&:blank?).any?(&:present?)
      end

      def item_price_for_id(item_id)
        price = item_prices.fetch(item_id.to_s, nil)
        price.present? ? price.to_m : nil
      end
    end
  end
end
