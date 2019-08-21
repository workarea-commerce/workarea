module Workarea
  module Inventory
    module Policies
      class Ignore < Base
        def displayable?
          true
        end

        def available_to_sell
          99999
        end

        def purchase(quantity)
          sku.inc(purchased: quantity)
          nil
        end
      end
    end
  end
end
