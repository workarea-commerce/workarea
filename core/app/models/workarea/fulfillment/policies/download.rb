module Workarea
  class Fulfillment
    module Policies
      class Download < Base
        def process(order_item:, fulfillment: nil)
          Fulfillment::Token.create!(
            order_id: order_item.order.id,
            order_item_id: order_item.id,
            sku: sku.id
          )

          return unless fulfillment.present?
          fulfillment.mark_item_shipped(
            id: order_item.id.to_s,
            quantity: order_item.quantity
          )
        end
      end
    end
  end
end
