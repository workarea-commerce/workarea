require 'test_helper'

module Workarea
  class AddressEqualityTest < Workarea::TestCase
    setup do
      @address_attributes = {
        first_name: 'Ben',
        last_name: 'Crouse',
        street: '22 S. 3rd St.',
        street_2: 'Second Floor',
        city: 'Philadelphia',
        region: 'PA',
        postal_code: '19106',
        country: 'US',
        phone_number: '2159251800'
      }

      @address = Address.new(@address_attributes)
    end

    def test_equal_attributes
      equal_address = Address.new(@address_attributes)
      assert(@address.address_eql?(equal_address))
    end

    def test_empty_address
      empty_address = Address.new
      refute(@address.address_eql?(empty_address))
    end

    def test_not_equal_attributes
      not_equal_address = Address.new(
        first_name: 'Ben',
        last_name: 'Crouse',
        street: '1019 S. 47th St.',
        city: 'Philadelphia',
        region: 'PA',
        postal_code: '19143',
        country: 'US',
        phone_number: '2159251800'
      )

      refute(@address.address_eql?(not_equal_address))
    end

    def test_ignoring_whitespace
      equal_address = Address.new(
        first_name: 'ben',
        last_name: 'crouse',
        street: ' 22 s. 3rd  st.',
        street_2: 'second   floor',
        city: 'philadelphia  ',
        region: 'pa',
        postal_code: '19106',
        country: 'us',
        phone_number: '2159251800'
      )

      assert(@address.address_eql?(equal_address))
    end
  end
end
