module Workarea
  module Inventory
    module Policies
      class Standard < Base
        def displayable?
          sku.purchasable?
        end

        def available_to_sell
          total_available = sku.available.to_i - sku.reserve.to_i
          total_available = 0 if total_available < 0
          total_available
        end

        def purchase(quantity)
          result = sku.capture(quantity)
          result = sku.capture(quantity) until result[:success]
          result
        end
      end
    end
  end
end
