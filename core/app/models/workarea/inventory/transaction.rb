module Workarea
  module Inventory
    class Transaction
      include ApplicationDocument

      field :order_id, type: String
      field :captured, type: Boolean, default: false

      index({ order_id: 1, captured: 1 })
      index({ updated_at: 1, captured: 1 })

      embeds_many :items,
        class_name: 'Workarea::Inventory::TransactionItem'

      # Creates a {Inventory::Transaction} based on order ID and items
      #
      # @param ID [String]
      # @param items [Hash] keys are skus, values are quantities
      #
      # @return [Inventory::Transaction]
      #
      def self.from_order(id, items)
        inventory_order = new(order_id: id)
        items.each do |sku, quantity|
          inventory_order.items.build(sku: sku, total: quantity)
        end

        inventory_order
      end

      def self.captured_for_order(id)
        find_by(order_id: id, captured: true) rescue nil
      end

      # Query for inventory orders that are expired. This means
      # they were never captured in 6 months.
      #
      # @return [Mongoid::Criteria]
      #
      def self.expired
        where(:updated_at.lt => Time.current - 6.months, captured: false)
      end

      # Capture the inventory quantities for this order.
      # This method uses MongoDB's findAndModify to
      # ensure we have valid inventory quantities to
      # capture against.
      #
      # When successful, it updates item states to
      # reflect what type of inventory (available vs backorder)
      # so we have this data from time of capture.
      #
      # This method is used when placing the order in checkout.
      #
      # @return [self]
      #
      def purchase
        unit = UnitOfWork.new(items)
        unit.commit

        self.captured = true
        save!

      rescue UnitOfWork::Failure => e
        self.captured = false
        errors.add(:base, e.message)

        self
      end

      # Reverts the operations from a capture to free up
      # the appropriate inventory. Used to rollback when
      # another order-placing dependency (e.g. payment)
      # fails.
      #
      # @return [self]
      #
      def rollback
        unit = UnitOfWork.new(items)
        unit.rollback

        self.captured = false
        save!

        self
      end

      # Reverts the operations from a capture to free up
      # the appropriate inventory. Used to restock
      # inventory when canceling an order item with that
      # option selected.
      #
      # @return [self]
      #
      def restock(quantities)
        UnitOfWork.new(items).restock(quantities)
        save!
        self
      end
    end
  end
end
