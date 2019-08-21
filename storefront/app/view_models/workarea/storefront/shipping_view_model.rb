module Workarea
  module Storefront
    class ShippingViewModel < ApplicationViewModel
      def items
        quantities
          .keys
          .map do |order_item_id|
            item = order.items.detect { |i| i.id.to_s == order_item_id }

            if item.present?
              copy = item.dup.tap { |c| c.quantity = quantities[order_item_id].to_i }
              Storefront::OrderItemViewModel.wrap(copy, options)
            end
          end
          .compact
      end

      def order
        options[:order] || Order.find(model.order_id)
      end

      def show_options?
        model.shippable?
      end
    end
  end
end
