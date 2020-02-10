module Workarea
  class Segment
    module Rules
      class TrafficReferrer < Base
        field :medium, type: String
        field :source, type: Array, default: []
        field :url, type: String

        def qualifies?(visit)
          medium_match?(visit.referrer) ||
            source_match?(visit.referrer) ||
            url_match?(visit.referrer)
        end

        def medium_match?(referrer)
          medium.present? && medium.to_s.strip.casecmp?(referrer.medium.to_s)
        end

        def source_match?(referrer)
          source.any? { |s| s.present? && s.to_s.strip.casecmp?(referrer.source.to_s) }
        end

        def url_match?(referrer)
          url.present? && referrer.uri.to_s =~ /#{url.strip}/i
        end
      end
    end
  end
end
