require 'test_helper'

module Workarea
  module Admin
    class ShippingServiceIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_creation
        shipping_service = {
          name:         'Shipping Service',
          tax_code:     '001',
          country:      'US',
          service_code: 'FED'
        }
        post admin.shipping_services_path,
          params: { service: shipping_service, new_rates: [{ price: '7.00' }] }

        assert_equal(1, Shipping::Service.count)

        service = Shipping::Service.first
        assert_equal('Shipping Service', service.name)
        assert_equal('001', service.tax_code)
        assert_equal(Country['US'], service.country)
        assert_equal('FED', service.service_code)
      end

      def test_update
        service = create_shipping_service(name: "test shipping")
        patch admin.shipping_service_path(service),
          params: { service: { name: 'foo bar'} }

        assert_equal(1, Shipping::Service.count)
        assert_equal('foo bar', Shipping::Service.first.name)
      end

      def test_can_update_the_shipping_rate_price_only
        service = create_shipping_service

        patch admin.shipping_service_path(service),
          params: {
          rates: {
            service.rates.first.id => {
              price: 30, tier_min: '', tier_max: ''
            }
          }
        }

        service.reload
        assert_equal(30.to_m, service.rates.first.price)
        assert_nil(service.rates.first.tier_min)
        assert_nil(service.rates.first.tier_max)
      end

      def test_can_create_rates_with_open_ended_tiers
        shipping_service = {
          name:         'Shipping Service',
          tax_code:     '001',
          country:      'US'
        }
        post admin.shipping_services_path,
          params: {
          service: shipping_service,
          new_rates: [{ price: '7.00', tier_min: '', tier_max: '100.00' }]
        }

        assert_equal(1, Shipping::Service.count)

        service = Shipping::Service.first
        assert_equal('Shipping Service', service.name)
        assert_nil(service.rates.first.tier_min)
        assert_equal(100.to_m, service.rates.first.tier_max)
      end

      def test_delete
        service = create_shipping_service
        delete admin.shipping_service_path(service)
        assert_equal(0, Shipping::Service.count)
      end
    end
  end
end
