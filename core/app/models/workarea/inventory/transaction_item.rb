module Workarea
  module Inventory
    class TransactionItem
      include ApplicationDocument

      field :sku, type: String
      field :available, type: Integer, default: 0
      field :backordered, type: Integer, default: 0
      field :backordered_until, type: Time
      field :total, type: Integer

      embedded_in :transaction, class_name: 'Workarea::Inventory::Transaction'

      def expired_backorder?
        !!backordered_until.try(:past?)
      end
    end
  end
end
