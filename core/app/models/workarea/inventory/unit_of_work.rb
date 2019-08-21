module Workarea
  module Inventory
    # This class handles the transaction details of doing an inventory
    # purchase or rollback.
    #
    class UnitOfWork
      class Failure < StandardError; end

      attr_reader :items

      def initialize(items)
        @items = items
      end

      # The {Sku}s collection for the items we're going to operate on.
      #
      # @return [Inventory::Collection]
      #
      def records
        @records ||= Inventory::Collection.new(items.map(&:sku).flatten)
      end

      # Perform the purchase and set the results on the items.
      # Rolls back any saved changed on an {InsufficientError}.
      #
      def commit
        items.each do |item|
          record = records.for_sku(item.sku)
          results = record.purchase(item.total)

          item.attributes = results.except(:success) if results.present?
        end

      rescue InsufficientError => e
        rollback
        raise Failure, e.message
      end

      # Roll back the purchase from all of the items. Also resets the items
      # to reflect that they have no captured inventory units.
      #
      def rollback
        items.each do |item|
          record = records.for_sku(item.sku)
          record.release(item.available, item.backordered)

          item.attributes = { available: 0, backordered: 0 }
        end
      end

      # Restock inventory from the purchase. Also updates the item quantities
      # to reflect the current state of captured inventory.
      #
      def restock(quantities = {})
        quantities.each do |sku, quantity|
          item = items.detect { |i| i.sku == sku }

          if item.expired_backorder?
            available_to_restock = quantity
            backordered_to_restock = 0
          else
            available_to_restock = [item.available, quantity].min
            backordered_to_restock = quantity - available_to_restock
          end

          record = records.for_sku(sku)
          record.release(available_to_restock, backordered_to_restock)

          available_restocked = [available_to_restock, item.available].min

          item.available -= available_restocked
          item.backordered -= if item.expired_backorder?
                                available_to_restock - available_restocked
                              else
                                backordered_to_restock
                              end
        end
      end
    end
  end
end
