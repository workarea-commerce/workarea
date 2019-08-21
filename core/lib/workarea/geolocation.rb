module Workarea
  class Geolocation
    class Address < Struct.new(:postal_code, :region, :country); end

    def initialize(env = {}, ip = nil)
      @env = env
      @ip = ip
    end

    def country
      Country[
        @env['HTTP_GEOIP2_DATA_COUNTRY_CODE'].presence ||
          @env['HTTP_GEOIP_CITY_COUNTRY_CODE'].presence ||
            request.try(:country_code)
      ]
    end

    def region
      region_from_geoip2.presence ||
        @env['HTTP_GEOIP_REGION'].presence ||
        request_data['region_code']
    end

    def city
      @env['HTTP_GEOIP2_DATA_CITY_NAME'].presence ||
        @env['HTTP_GEOIP_CITY'].presence ||
        request.try(:city)
    end

    def postal_code
      @env['HTTP_GEOIP_POSTAL_CODE'].presence || request.try(:postal_code)
    end

    def latitude
      @env['HTTP_GEOIP2_DATA_LATITUDE'].presence ||
        @env['HTTP_GEOIP_LATITUDE'].presence ||
        request.try(:latitude)
    end

    def longitude
      @env['HTTP_GEOIP2_DATA_LONGITUDE'].presence ||
        @env['HTTP_GEOIP_LONGITUDE'].presence ||
        request.try(:longitude)
    end

    # @return [Array<Number>] or +nil+ if neither latitude nor longitude
    # can be found
    def coordinates
      return unless latitude.present? && longitude.present?
      [latitude, longitude]
    end

    private

    def request
      @request ||= Geocoder.search(@ip).first
    end

    def region_from_geoip2
      return unless country.present?
      match = country.subdivisions.find do |iso_code, subdivision|
        subdivision.name == @env['HTTP_GEOIP2_DATA_REGION_NAME']
      end
      match&.first
    end

    def request_data
      request.try(:data) || {}
    end
  end
end
