module Workarea
  class Fulfillment
    module Policies
      class Base
        attr_reader :sku

        def initialize(sku)
          @sku = sku
        end

        def process(order_item:, fulfillment: nil)
          raise(NotImplementedError)
        end
      end
    end
  end
end
