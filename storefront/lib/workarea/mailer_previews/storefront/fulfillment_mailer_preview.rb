module Workarea
  module Storefront
    class FulfillmentMailerPreview < ActionMailer::Preview
      def shipped
        fulfillment = Fulfillment.all.detect { |f| f.packages.present? }

        FulfillmentMailer.shipped(
          fulfillment.id,
          fulfillment.packages.first.tracking_number
        )
      end

      def canceled
        fulfillment = Fulfillment.all.detect { |f| f.canceled_items.present? }

        quantities = fulfillment.canceled_items.map do |item|
          [
            BSON::ObjectId.from_string(item.order_item_id),
            item.quantity_canceled
          ]
        end.to_h

        FulfillmentMailer.canceled(fulfillment.id, quantities)
      end
    end
  end
end
