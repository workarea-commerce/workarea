require 'test_helper'

module Workarea
  class Shipping
    class RateLookupTest < TestCase

      setup :set_shipping_services

      def address
        @address ||= Address.new
      end

      def sku
        @sku ||= create_shipping_sku
      end

      def packages
        @packages ||= [
          ActiveShipping::Package.new(sku.weight, sku.dimensions)
        ]
      end

      def set_shipping_services
        @shipping_services = [
          create_shipping_service(rates: [{ price: 1 }]),
          create_shipping_service(rates: [{ price: 2 }])
        ]
      end

      def test_response
        response = RateLookup.new(address, address, packages).response
        first_rate = response.rates.first

        assert_equal(@shipping_services.first.name, first_rate.service_name)
        assert_equal(100, first_rate.price) # ActiveShipping works in cents
      end

      def test_restriction_by_location
        create_shipping_service(name: 'US', country: 'US')
        create_shipping_service(name: 'PA', country: 'US', regions: ['PA'])

        address = Address.new(country: 'CA')
        response = RateLookup.new(address, address, packages).response
        refute_includes(response.rates.map(&:service_name), 'US')

        address = Address.new(country: 'US', region: 'NJ')
        response = RateLookup.new(address, address, packages).response
        refute_includes(response.rates.map(&:service_name), 'PA')
      end

      def test_restriction_by_subtotal
        packages = [
          ActiveShipping::Package.new(sku.weight, sku.dimensions, value: 4.to_m)
        ]
        create_shipping_service(name: 'Unavailable', subtotal_min: 5.to_m)

        response = RateLookup.new(address, address, packages).response
        refute_includes(response.rates.map(&:service_name), 'Unavailable')
      end

      def test_restriction_by_tiered_pricing
        packages = [
          ActiveShipping::Package.new(sku.weight, sku.dimensions, value: 4.to_m)
        ]

        create_shipping_service(
          name: 'Unavailable',
          rates: [{ price: 1, tier_min: 5.to_m }]
        )

        response = RateLookup.new(address, address, packages).response
        refute_includes(response.rates.map(&:service_name), 'Unavailable')
      end
    end
  end
end
