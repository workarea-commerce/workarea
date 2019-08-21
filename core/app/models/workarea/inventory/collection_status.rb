module Workarea
  module Inventory
    module CollectionStatus
      class Backordered
        include StatusCalculator::Status

        def in_status?
          model.any?(&:allow_backorder?) &&
            model.sum(&:backordered).positive? &&
            model.sum(&:available).zero?
        end
      end

      class LowInventory
        include StatusCalculator::Status

        def in_status?
          model.purchasable? &&
            !model.purchasable?(Workarea.config.low_inventory_threshold)
        end
      end

      class OutOfStock
        include StatusCalculator::Status

        def in_status?
          !model.purchasable?
        end
      end

      class Available
        include StatusCalculator::Status

        def in_status?
          model.purchasable?
        end
      end
    end
  end
end
