module Workarea
  module Inventory
    module Policies
      class AllowBackorder < Base
        def displayable?
          sku.purchasable?
        end

        def available_to_sell
          total_available =
            sku.available.to_i + sku.backordered.to_i - sku.reserve.to_i
          total_available = 0 if total_available < 0
          total_available
        end

        def purchase(quantity)
          result = try_capture(quantity)
          result = try_capture(quantity) until result[:success]
          result
        end

        private

        def try_capture(quantity)
          if sku.available >= quantity
            available = quantity
            backordered = 0
          else
            available = sku.available
            backordered = quantity - sku.available
          end

          sku.capture(available, backordered)
        end
      end
    end
  end
end
