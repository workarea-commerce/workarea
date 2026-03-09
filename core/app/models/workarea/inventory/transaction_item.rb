# frozen_string_literal: true

module Workarea
  module Inventory
    class TransactionItem
      include ApplicationDocument

      field :sku, type: String
      field :available, type: Integer, default: 0
      field :backordered, type: Integer, default: 0
      field :backordered_until, type: Time
      field :total, type: Integer

      # Mongoid 9.x reserves `transaction` for session handling, so we avoid
      # defining an association with that name.
      embedded_in :inventory_transaction,
        class_name: 'Workarea::Inventory::Transaction',
        inverse_of: :items,
        touch: false

      def expired_backorder?
        !!backordered_until.try(:past?)
      end
    end
  end
end
