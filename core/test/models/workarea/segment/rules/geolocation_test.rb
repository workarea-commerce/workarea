require 'test_helper'

module Workarea
  class Segment
    module Rules
      class GeolocationTest < TestCase
        def test_qualifies?
          refute(Geolocation.new.qualifies?(create_visit))

          visit = create_visit(
            'HTTP_GEOIP_REGION' => 'PA',
            'HTTP_GEOIP_CITY_COUNTRY_CODE' => 'US'
          )
          refute(Geolocation.new(locations: %w(NJ)).qualifies?(visit))
          assert(Geolocation.new(locations: %w(us-pa)).qualifies?(visit))
          assert(Geolocation.new(locations: %w(US-PA)).qualifies?(visit))
          assert(Geolocation.new(locations: %w(US-NJ US-pa)).qualifies?(visit))
          refute(Geolocation.new(locations: %w(US-NJ US-NY)).qualifies?(visit))

          visit = create_visit(
            'HTTP_GEOIP_REGION' => 'PA',
            'HTTP_GEOIP_CITY_COUNTRY_CODE' => 'US'
          )
          assert(Geolocation.new(locations: %w(Pennsylvania)).qualifies?(visit))
          assert(Geolocation.new(locations: %w(US-PA)).qualifies?(visit))

          visit = create_visit('HTTP_GEOIP_CITY' => 'Philadelphia')
          assert(Geolocation.new(locations: %w(philadelphia)).qualifies?(visit))
          assert(Geolocation.new(locations: %w(Philadelphia)).qualifies?(visit))
          assert(Geolocation.new(locations: %w(Philadelphia US)).qualifies?(visit))
          refute(Geolocation.new(locations: %w(Harrisburg)).qualifies?(visit))
          refute(Geolocation.new(locations: %w(Harrisburg US-PA)).qualifies?(visit))
          assert(Geolocation.new(locations: %w(Philadelphia Harrisburg)).qualifies?(visit))
          refute(Geolocation.new(locations: %w(Pittsburgh Harrisburg)).qualifies?(visit))

          visit = create_visit('HTTP_GEOIP_CITY_COUNTRY_CODE' => 'US')
          refute(Geolocation.new(locations: %w(CA)).qualifies?(visit))
          assert(Geolocation.new(locations: %w(US)).qualifies?(visit))
          assert(Geolocation.new(locations: ['United States of America']).qualifies?(visit))
          assert(Geolocation.new(locations: %w(Philadelphia US)).qualifies?(visit))
          assert(Geolocation.new(locations: %w(US CA)).qualifies?(visit))
          refute(Geolocation.new(locations: %w(MX CA)).qualifies?(visit))

          visit = create_visit('HTTP_GEOIP_POSTAL_CODE' => '19106')
          assert(Geolocation.new(locations: %w(19106)).qualifies?(visit))
          refute(Geolocation.new(locations: %w(19147)).qualifies?(visit))
        end
      end
    end
  end
end
