require 'test_helper'

module Workarea
  class ShippingOptionTest < TestCase
    def test_from_rate_estimate
      rate_estimate = ActiveShipping::RateEstimate.new(
        Address.new,
        Address.new,
        'UPS',
        'Ground',
        service_code: '03',
        total_price: 700,
        currency: 'USD'
      )

      create_shipping_service(carrier: 'UPS', name: 'Ground', tax_code: '001')
      create_shipping_service(carrier: 'UPS', name: '2 Day', tax_code: '002')

      result = ShippingOption.from_rate_estimate(rate_estimate)
      assert_equal('UPS', result.carrier)
      assert_equal('Ground', result.name)
      assert_equal('03', result.service_code)
      assert_equal('001', result.tax_code)
      assert_equal(7.to_m, result.price)
    end

    def test_price
      shipping_service = create_shipping_service(rates: [{ price: 3.to_m }])

      adjustment = PriceAdjustment.new(amount: -1.to_m)
      option = ShippingOption.new(
        shipping_service.attributes.merge(price: 3.to_m)
      )

      option.price_adjustments = [adjustment]

      assert_equal(2.to_m, option.price)
    end

    def test_price_guards_against_price_adjustments
      shipping_service = create_shipping_service(rates: [{ price: 3.to_m }])

      adjustment = PriceAdjustment.new(amount: -10.to_m)
      option = ShippingOption.new(shipping_service.attributes)
      option.price_adjustments = [adjustment]

      assert_equal(0.to_m, option.price)
    end
  end
end
