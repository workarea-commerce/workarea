module Workarea
  module Factories
    module Fulfillment
      Factories.add(self)

      def fulfill_order(order)
        fulfillment = Fulfillment.find(order.id) rescue nil
        fulfillment ||= create_fulfillment_from_order(order)
        fulfillment.ship_items(
          '1z1243',
          order.items.map { |i| { id: i.id, quantity: i.quantity } }
        )
      end

      def create_fulfillment_from_order(order)
        create = CreateFulfillment.new(order).tap(&:perform)
        create.fulfillment
      end
    end
  end
end
