module Workarea
  class Fulfillment
    class Token
      include ApplicationDocument

      field :_id, type: String, default: -> { SecureRandom.base58(24) }
      field :order_id, type: String
      field :order_item_id, type: String
      field :sku, type: String
      field :enabled, type: Boolean, default: true
      field :downloads, type: Integer, default: 0

      index(order_id: 1, order_item_id: 1)
      index(sku: 1)

      scope :for_sku, ->(sku) { where(sku: sku) }
      scope :by_order, ->(id) { where(order_id: id) }

      def self.for_order_item(order_id, item_id)
        where(order_id: order_id.to_s, order_item_id: item_id.to_s).first
      end

      def self.sorts
        [Sort.newest, Sort.modified, Sort.downloads]
      end

      def disabled?
        !enabled?
      end

      def from_user_order?
        user_id.present? && order_id.present?
      end
    end
  end
end
