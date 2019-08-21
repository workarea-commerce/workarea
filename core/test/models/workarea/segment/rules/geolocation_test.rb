require 'test_helper'

module Workarea
  class Segment
    module Rules
      class GeolocationTest < TestCase
        def test_qualifies?
          refute(Geolocation.new.qualifies?(create_visit))

          visit = create_visit('HTTP_GEOIP_REGION' => 'PA')
          refute(Geolocation.new(region: 'NJ').qualifies?(visit))
          assert(Geolocation.new(region: 'pa').qualifies?(visit))
          assert(Geolocation.new(region: 'PA ').qualifies?(visit))
          assert(Geolocation.new(city: 'Philadelphia', region: 'PA').qualifies?(visit))

          visit = create_visit('HTTP_GEOIP_REGION' => nil)
          refute(Geolocation.new(region: 'pa').qualifies?(visit))

          visit = create_visit('HTTP_GEOIP_CITY' => 'Philadelphia')
          assert(Geolocation.new(city: 'philadelphia').qualifies?(visit))
          assert(Geolocation.new(city: 'Philadelphia ').qualifies?(visit))
          assert(Geolocation.new(city: 'Philadelphia', country: 'US').qualifies?(visit))
          refute(Geolocation.new(city: 'Harrisburg').qualifies?(visit))
          refute(Geolocation.new(city: 'Harrisburg', region: 'PA').qualifies?(visit))

          visit = create_visit('HTTP_GEOIP_CITY_COUNTRY_CODE' => 'US')
          refute(Geolocation.new(country: 'CA').qualifies?(visit))
          assert(Geolocation.new(country: 'US').qualifies?(visit))
          assert(Geolocation.new(city: 'Philadelphia', country: 'US').qualifies?(visit))
        end
      end
    end
  end
end
