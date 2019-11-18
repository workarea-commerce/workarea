module Workarea
  class Segment
    module Rules
      class LastOrder < Base
        field :within, type: Boolean, default: true
        field :days, type: Integer

        def qualifies?(visit)
          return false if days.blank?
          return !within if visit.metrics.last_order_at.blank?

          if within?
            visit.metrics.last_order_at >= days.days.ago
          else
            visit.metrics.last_order_at < days.days.ago
          end
        end
      end
    end
  end
end
