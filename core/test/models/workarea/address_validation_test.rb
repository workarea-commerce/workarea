require 'test_helper'

module Workarea
  class AddressValidationTest < Workarea::TestCase
    setup :set_config
    teardown :reset_config

    def set_config
      @current_countries = Workarea.config.countries
      Workarea.config.countries = [Country['US'], Country['AW']]
    end

    def reset_config
      Workarea.config.countries = @current_countries
    end

    def test_country_validation
      address = Address.new

      address.country = 'US'
      address.valid?
      assert_empty(address.errors[:country])

      address.country = 'Not a Real Country'
      address.valid?
      assert_not_empty(address.errors[:country])
    end

    def test_postal_code_validation
      address = Address.new

      address.country = 'US'
      address.postal_code = nil
      address.valid?
      assert_not_empty(address.errors[:postal_code])

      address.country = 'US'
      address.postal_code = '12345'
      address.valid?
      assert_empty(address.errors[:postal_code])

      address.country = 'AW'
      address.postal_code = nil
      address.valid?
      assert_empty(address.errors[:postal_code])

      address.country = 'AW'
      address.postal_code = '12345FOO'
      address.valid?
      assert_empty(address.errors[:postal_code])
    end

    def test_region_validation
      address = Address.new

      address.country = 'US'
      address.region = nil
      refute(address.valid?)
      assert_not_empty(address.errors[:region])

      address.country = 'US'
      address.region = 'PA'
      address.valid?
      assert_empty(address.errors[:region])

      address.country = 'AW'
      address.region = nil
      address.valid?
      assert_empty(address.errors[:region])
    end

    def test_field_length_validation
      fields = [
        :first_name,
        :last_name,
        :company,
        :street,
        :street_2,
        :city,
        :region,
        :postal_code,
        :country,
        :phone_number,
        :phone_extension
      ]

      fields.each do |field|
        address = Address.new(field => '0' * 1_000)
        address.valid?
        assert_not_empty(address.errors[field])
      end
    end
  end
end
