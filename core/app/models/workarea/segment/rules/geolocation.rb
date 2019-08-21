module Workarea
  class Segment
    module Rules
      class Geolocation < Base
        field :city, type: String
        field :region, type: String
        field :country, type: Country

        def qualifies?(visit)
          return false if country.blank? && region.blank? && city.blank?
          return false if visit.country.blank? && visit.region.blank? && visit.city.blank?

          (visit.country.blank? || country_match?(visit)) &&
            (visit.region.blank? || region_match?(visit)) &&
            (visit.city.blank? || city_match?(visit))
        end

        def city_match?(visit)
          city.blank? || city.strip.casecmp?(visit.city.to_s.strip)
        end

        def region_match?(visit)
          region.blank? || region.strip.casecmp?(visit.region.to_s.strip)
        end

        def country_match?(visit)
          country.blank? || country == visit.country
        end
      end
    end
  end
end
