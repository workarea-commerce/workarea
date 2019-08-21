module Workarea
  class Shipping
    class LocationQuery
      attr_reader :services, :country, :region

      def initialize(services, country, region)
        @services = services
        @country = typecast_country(country)
        @region = region
      end

      def location_services
        location_services = matching_services

        if has_service_with_region?
          location_services.select! do |service|
            service.regions.include?(region)
          end
        end

        location_services
      end

      private

      def matching_services
        @matching_services ||= services.select do |service|
          (country.blank? || service.country.blank? || service.country == country) &&
            (region.blank? || service.regions.blank? || service.regions.include?(region))
        end
      end

      def has_service_with_region?
        region.present? &&
          matching_services.detect { |service| service.regions.include?(region) }
      end

      def typecast_country(country)
        if country.is_a?(::Country)
          country
        elsif country.is_a?(String)
          Country[country]
        elsif country.is_a?(ActiveUtils::Country)
          Country[country.code(:alpha2)]
        end
      end
    end
  end
end
