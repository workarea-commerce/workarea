module Workarea
  class Segment
    module Rules
      class Revenue < Base
        field :minimum, type: Money
        field :maximum, type: Money

        def qualifies?(visit)
          return false if minimum.blank? && maximum.blank?

          (minimum.blank? || visit.metrics.revenue.to_m >= minimum) &&
            (maximum.blank? || visit.metrics.revenue.to_m <= maximum)
        end
      end
    end
  end
end
