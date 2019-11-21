module Workarea
  class Fulfillment
    module Policies
      class Shipping < Base
        def process(*)
          # no op
        end
      end
    end
  end
end
