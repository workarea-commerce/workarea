module Workarea
  class Fulfillment
    class Event
      include ApplicationDocument

      field :status, type: String
      field :quantity, type: Integer, default: 0
      field :data, type: Hash, default: {}

      embedded_in :item, inverse_of: :events
      delegate :order_item_id, to: :item
    end
  end
end
