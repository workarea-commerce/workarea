module Workarea
  class Segment
    module Rules
      class Orders < Base
        field :minimum, type: Integer
        field :maximum, type: Integer

        def qualifies?(visit)
          return false if minimum.blank? && maximum.blank?

          (minimum.blank? || visit.metrics.orders >= minimum) &&
            (maximum.blank? || visit.metrics.orders <= maximum)
        end
      end
    end
  end
end
