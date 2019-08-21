module Workarea
  class Segment
    module Rules
      class TrafficReferrer < Base
        field :medium, type: String
        field :source, type: String

        def qualifies?(visit)
          return false if medium.blank? && source.blank?
          return false unless visit.referrer[:known]

          (medium.blank? || medium.strip.casecmp?(visit.referrer[:medium])) &&
            (source.blank? || visit.referrer[:source].to_s =~ /#{source.strip}/i)
        end
      end
    end
  end
end
