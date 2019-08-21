module Workarea
  module Storefront
    class FulfillmentMailer < Storefront::ApplicationMailer
      include TransactionalMailer

      def shipped(order_id, tracking_number)
        order = Order.find(order_id)
        @order = Storefront::OrderViewModel.new(order)

        fulfillment = Fulfillment.find_or_initialize_by(id: order_id)
        package = fulfillment.find_package(tracking_number)
        @package = Storefront::PackageViewModel.new(package, order: @order)
        @recommendations = Storefront::EmailRecommendationsViewModel.wrap(order)

        mail(
          to: @order.email,
          subject: t(
            'workarea.storefront.email.order_shipped.subject',
            order_id: @order.id
          )
        )
      end

      def canceled(order_id, quantities)
        model = Order.find(order_id)
        @order = Storefront::OrderViewModel.new(model)
        @recommendations = Storefront::EmailRecommendationsViewModel.wrap(model)

        @cancellations = quantities # TODO: Remove in v4, no longer needed.
        @canceled_items ||= quantities.keys.map do |item_id|
          item = @order.items.detect { |i| i.id.to_s == item_id.to_s }
          next unless item.present?

          FulfillmentItemViewModel.new(item, quantity: quantities[item_id])
        end.compact

        mail(
          to: @order.email,
          subject: t(
            'workarea.storefront.email.order_cancellation.subject',
            order_id: @order.id
          )
        )
      end
    end
  end
end
