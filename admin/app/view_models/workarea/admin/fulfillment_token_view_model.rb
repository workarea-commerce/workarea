module Workarea
  module Admin
    class FulfillmentTokenViewModel < ApplicationViewModel
      def order
        return unless order_id.present?
        @order ||= options[:order] || Order.find(order_id)
      end

      def order_item
        return unless order.present? && order_item_id.present?
        @order_item ||= order.items.detect { |i| i.id.to_s == order_item_id }
      end
    end
  end
end
