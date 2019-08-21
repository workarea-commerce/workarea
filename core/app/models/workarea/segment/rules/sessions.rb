module Workarea
  class Segment
    module Rules
      class Sessions < Base
        field :minimum, type: Integer
        field :maximum, type: Integer

        def qualifies?(visit)
          return false if minimum.blank? && maximum.blank?

          (minimum.blank? || visit.sessions >= minimum) &&
            (maximum.blank? || visit.sessions <= maximum)
        end
      end
    end
  end
end
