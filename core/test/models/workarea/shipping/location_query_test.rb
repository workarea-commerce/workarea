require 'test_helper'

module Workarea
  class Shipping
    class LocationQueryTest < TestCase
      def test_location_services
        pa_service = create_shipping_service(country: 'US', regions: ['PA'])
        generic = create_shipping_service
        methods = [pa_service, generic]


        location_services = Workarea::Shipping::LocationQuery.new(
          methods,
          Country['US'],
          'PA'
        ).location_services

        refute_includes(location_services.map(&:id), generic.id)
        assert_includes(location_services.map(&:id), pa_service.id)

        location_services = Workarea::Shipping::LocationQuery.new(
          methods,
          Country['US'],
          'CA'
        ).location_services

        assert_includes(location_services.map(&:id), generic.id)
        refute_includes(location_services.map(&:id), pa_service.id)
      end

      def test_initialize_with_different_country_types
        pa_service = create_shipping_service(country: 'US', regions: ['PA'])
        ca_service = create_shipping_service(country: 'US', regions: ['CA'])
        services = [pa_service, ca_service]

        as_string = Workarea::Shipping::LocationQuery.new(
          services,
          'US',
          'PA'
        ).country

        as_country = Workarea::Shipping::LocationQuery.new(
          services,
          Country['US'],
          'PA'
        ).country

        as_active_utils = Workarea::Shipping::LocationQuery.new(
          services,
          ActiveUtils::Country.find('US'),
          'PA'
        ).country

        assert_equal(Country['US'], as_string)
        assert_equal(Country['US'], as_country)
        assert_equal(Country['US'], as_active_utils)
      end
    end
  end
end
