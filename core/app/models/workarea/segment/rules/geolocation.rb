module Workarea
  class Segment
    module Rules
      class Geolocation < Base
        field :locations, type: Array, default: []

        def qualifies?(visit)
          return false if locations.blank?

          visit_locations = matchable_locations_for(visit)
          return false if visit_locations.blank?

          matchable_locations = locations.map(&:downcase)
          visit_locations.any? { |l| l.in?(matchable_locations) }
        end

        def matchable_locations_for(visit)
          option_ids = [
            visit.postal_code,
            GeolocationOption.from_subdivision(visit.country, visit.subdivision)&.id,
            GeolocationOption.from_country(visit.country)&.id
          ]

          (visit.location_names + option_ids).reject(&:blank?).map(&:downcase)
        end
      end
    end
  end
end
