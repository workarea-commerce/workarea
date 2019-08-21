module Workarea
  class Fulfillment
    module Policies
      class Ignore < Base
        def process(*args)
          # no op
        end
      end
    end
  end
end
