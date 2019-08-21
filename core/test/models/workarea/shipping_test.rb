require 'test_helper'

module Workarea
  class ShippingTest < TestCase
    def test_shippable
      shipping = Shipping.new
      shipping.shipping_service = nil
      shipping.set_address(
        first_name: 'Ben',
        last_name: 'Crouse',
        street: '22 S. 3rd St.',
        street_2: 'Second Floor',
        city: 'Philadelphia',
        region: 'PA',
        postal_code: '19106',
        country: 'US'
      )

      refute(shipping.shippable?)

      shipping.address = nil
      shipping.set_shipping_service(name: 'Test Method')
      refute(shipping.shippable?)

      shipping.set_address(
        last_name: 'Crouse',
        street: '22 S. 3rd St.',
        street_2: 'Second Floor',
        city: 'Philadelphia',
        region: 'PA',
        postal_code: '19106',
        country: 'US'
      )

      refute(shipping.shippable?)

      shipping.set_address(
        first_name: 'Ben',
        last_name: 'Crouse',
        street: '22 S. 3rd St.',
        street_2: 'Second Floor',
        city: 'Philadelphia',
        region: 'PA',
        postal_code: '19106',
        country: 'US'
      )

      assert(shipping.shippable?)
    end

    def test_set_address
      shipping = Shipping.new

      shipping.set_address(
        first_name: 'Ben',
        last_name: 'Crouse',
        street: '22 S. 3rd St.',
        street_2: 'Second Floor',
        city: 'Philadelphia',
        region: 'PA',
        postal_code: '19106',
        country: 'US'
      )

      assert_equal('Ben', shipping.address.first_name)
      assert_equal('Crouse', shipping.address.last_name)
      assert_equal('22 S. 3rd St.', shipping.address.street)
      assert_equal('Second Floor', shipping.address.street_2)
      assert_equal('Philadelphia', shipping.address.city)
      assert_equal('PA', shipping.address.region)
      assert_equal('19106', shipping.address.postal_code)
      assert_equal(Country['US'], shipping.address.country)
    end

    def test_set_shipping_service
      shipping = Shipping.new
      shipping.set_shipping_service(name: 'Test Method')
      assert_equal('Test Method', shipping.shipping_service.name)
    end

    def test_find_method_options
      create_shipping_service(name: '2 Day', rates: [{ price: 2 }])
      create_shipping_service(name: 'Ground', rates: [{ price: 1 }])

      shipping = Shipping.new
      shipping.set_address(
        first_name: 'Ben',
        last_name: 'Crouse',
        street: '22 S. 3rd St.',
        street_2: 'Second Floor',
        city: 'Philadelphia',
        region: 'PA',
        postal_code: '19106',
        country: 'US'
      )

      results = shipping.find_method_options(
        [ActiveShipping::Package.new(3, [1, 2, 3], value: 4.to_m)]
      )

      assert_equal(2, results.length)
      assert_equal('Ground', results.first.name)
      assert_equal('2 Day', results.second.name)
    end
  end
end
