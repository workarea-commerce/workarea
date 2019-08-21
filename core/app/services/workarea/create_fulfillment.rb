module Workarea
  class CreateFulfillment
    def initialize(order)
      @order = order
    end

    def fulfillment
      @fulfillment ||= Fulfillment.find_or_initialize_by(id: @order.id)
    end

    def perform
      @order.items.each do |item|
        next if fulfillment.items.detect { |i| i.order_item_id == item.id.to_s }
        fulfillment.items.build(order_item_id: item.id, quantity: item.quantity)

        Fulfillment::Sku.process!(
          item.sku,
          order_item: item,
          fulfillment: fulfillment
        )
      end

      fulfillment.save!
    end
  end
end
