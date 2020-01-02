module Workarea
  class Fulfillment
    class Item
      include ApplicationDocument

      field :order_item_id, type: String
      field :quantity, type: Integer, default: 0

      embeds_many :events, class_name: 'Workarea::Fulfillment::Event', inverse_of: :item

      embedded_in :fulfillment, class_name: 'Workarea::Fulfillment'

      def quantity_pending
        [0, quantity - events.sum(&:quantity)].max
      end

      def method_missing(method_name, *args)
        if method_name =~ /^quantity_/
          status = method_name.to_s.gsub(/^quantity_/, '')
          events.where(status: status).sum(&:quantity)
        else
          super
        end
      end
    end
  end
end
