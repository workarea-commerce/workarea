module Workarea
  module Storefront
    class PackageViewModel < ApplicationViewModel
      include ShippingCarrierViewModel

      def items
        @items ||= model.events_by_item.map do |order_item_id, events|
          order_item = order.items.detect { |i| i.id.to_s == order_item_id }
          next if order_item.blank?

          FulfillmentItemViewModel.new(order_item, events: events)
        end.compact
      end

      def order
        options[:order] || OrderViewModel.wrap(Order.find(model.order_id))
      end
    end
  end
end
