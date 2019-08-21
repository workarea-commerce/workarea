module Workarea
  class Segment
    module Rules
      class LastOrder < Base
        field :days, type: Integer

        def qualifies?(visit)
          return false if visit.metrics.last_order_at.blank? || days.blank?
          visit.metrics.last_order_at >= days.days.ago
        end
      end
    end
  end
end
