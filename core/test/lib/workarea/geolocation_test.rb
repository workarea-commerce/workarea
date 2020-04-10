require 'test_helper'

module Workarea
  class GeolocationTest < TestCase
    def test_country_uses_the_env_value
      location = Geolocation.new({ 'HTTP_GEOIP_CITY_COUNTRY_CODE' => 'US' })
      assert_equal(Country['US'], location.country)
    end

    def test_region_uses_the_env_value
      location = Geolocation.new('HTTP_GEOIP_REGION' => 'PA')
      assert_equal('PA', location.region)
    end

    def test_city_uses_the_env_value
      location = Geolocation.new('HTTP_GEOIP_CITY' => 'Philadelphia')
      assert_equal('Philadelphia', location.city)
    end

    def test_postal_code_uses_the_env_value
      location = Geolocation.new('HTTP_GEOIP_POSTAL_CODE' => '19106')
      assert_equal('19106', location.postal_code)
    end

    def test_coordinates_uses_the_env_value
      location = Geolocation.new(
        'HTTP_GEOIP_LATITUDE' => 40.155,
        'HTTP_GEOIP_LONGITUDE' => -75.381
      )

      assert_equal([40.155, -75.381], location.coordinates)
    end

    def test_country_uses_the_geoip2_env_value
      location = Geolocation.new({ 'HTTP_GEOIP2_DATA_COUNTRY_CODE' => 'US' })
      assert_equal(Country['US'], location.country)
    end

    def test_region_uses_the_geoip2_env_value
      location = Geolocation.new(
        'HTTP_GEOIP2_DATA_COUNTRY_CODE' => 'US',
        'HTTP_GEOIP2_DATA_REGION_NAME' => 'Pennsylvania'
      )
      assert_equal('PA', location.region)
    end

    def test_city_uses_the_geoip2_env_value
      location = Geolocation.new('HTTP_GEOIP2_DATA_CITY_NAME' => 'Philadelphia')
      assert_equal('Philadelphia', location.city)
    end

    def test_coordinates_uses_the_geoip2_env_value
      location = Geolocation.new(
        'HTTP_GEOIP2_DATA_LATITUDE' => 40.155,
        'HTTP_GEOIP2_DATA_LONGITUDE' => -75.381
      )

      assert_equal([40.155, -75.381], location.coordinates)
    end

    def test_handles_missing_geocode_data
      location = Geolocation.new(
        'HTTP_GEOIP_LATITUDE' => nil,
        'HTTP_GEOIP_LONGITUDE' => nil
      )
      location.stubs(:request).returns(mock('Geocoder::Request'))

      assert_nil(location.coordinates)
    end

    def test_region_defaults_to_request_data
      request = mock('Geocoder::Request', data: { 'region_code' => 'PA' })
      location = Geolocation.new
      location.stubs(:request).returns(request)

      assert_equal('PA', location.region)
    end

    def test_region_defaults_to_nil
      location = Geolocation.new
      location.stubs(:request).returns(nil)

      assert_nil(location.region)
    end

    def test_location_names
      location = Geolocation.new
      assert_equal([], location.names)

      location = Geolocation.new(
        'HTTP_GEOIP2_DATA_COUNTRY_CODE' => 'US',
        'HTTP_GEOIP2_DATA_REGION_NAME' => 'Pennsylvania',
        'HTTP_GEOIP2_DATA_CITY_NAME' => 'Philadelphia',
        'HTTP_GEOIP_POSTAL_CODE' => '19106'
      )

      refute_includes(location.names, 'US')
      refute_includes(location.names, 'USA')
      assert_includes(location.names, 'United States of America')
      refute_includes(location.names, 'PA')
      assert_includes(location.names, 'Pennsylvania')
      assert_includes(location.names, 'Philadelphia')
      assert_includes(location.names, '19106')
    end
  end
end
