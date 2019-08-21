module Workarea
  class Fulfillment
    module Policies
      class Ship < Base
        def requires_shipping?
          true
        end

        def process(*args)
          # no op
        end
      end
    end
  end
end
