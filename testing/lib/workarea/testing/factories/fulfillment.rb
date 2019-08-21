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

      def create_fulfillment_sku(overrides = {})
        attributes = factory_defaults(:fulfillment_sku).merge(overrides)
        Workarea::Fulfillment::Sku.create!(attributes)
      end

      def create_fulfillment_token(overrides = {})
        attributes = factory_defaults(:fulfillment_token).merge(overrides)
        Workarea::Fulfillment::Token.create!(attributes)
      end
    end
  end
end
