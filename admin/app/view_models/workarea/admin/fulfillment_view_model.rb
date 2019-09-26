module Workarea
  module Admin
    class FulfillmentViewModel < ApplicationViewModel
      def order
        options[:order] || OrderViewModel.wrap(Order.find(model.id))
      end

      def packages
        @packages ||= model.packages.map do |package|
          PackageViewModel.new(package, order: order)
        end
      end

      def pending_items
        @pending_items ||= model.pending_items.map do |fulfillment_item|
          next unless order_item = order
            .items
            .detect { |i| i.id.to_s == fulfillment_item.order_item_id }

          FulfillmentItemViewModel.new(
            order_item,
            quantity: fulfillment_item.quantity_pending
          )
        end.compact
      end

      def cancellations
        @cancellations ||= model.canceled_items.map do |fulfillment_item|
          next unless order_item = order
            .items
            .detect { |i| i.id.to_s == fulfillment_item.order_item_id }

          FulfillmentItemViewModel.new(
            order_item,
            quantity: fulfillment_item.quantity_canceled
          )
        end.compact
      end

      def skus
        @skus ||= FulfillmentSkusViewModel.wrap(
          Fulfillment::Sku.in(id: order.items.map(&:sku).uniq).to_a,
          options
        )
      end

      def tokens
        @tokens ||= FulfillmentTokenViewModel.wrap(
          Fulfillment::Token.by_order(order.id).to_a,
          options.merge(order: order)
        )
      end
    end
  end
end
