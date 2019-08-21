module Workarea
  module Inventory
    module Policies
      class DisplayableWhenOutOfStock < Standard
        def displayable?
          true
        end
      end
    end
  end
end
