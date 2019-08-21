module Workarea
  class Shipping
    class RateLookup
      attr_reader :origin, :destination, :packages, :options

      def initialize(origin, destination, packages, options = {})
        @origin = origin
        @destination = destination
        @packages = packages
        @options = options
      end

      def localized_services
        @localized_services ||= if destination.present?
                                  Shipping::Service.for_location(
                                    destination.country,
                                    destination.region
                                  )
                                else
                                  Shipping::Service.all.to_a
                                end
      end

      def subtotal
        @subtotal ||= packages.map { |p| Money.new(p.value, p.currency) }.sum
      end

      def valid_services
        localized_services & Shipping::Service.by_price(subtotal)
      end

      def response
        ActiveShipping::RateResponse.new(
          true, # success
          'success', # message
          {}, # params
          rates: valid_services.map do |service|
            total = service.find_rate(subtotal).try(:price)
            next unless total.present?

            ActiveShipping::RateEstimate.new(
              origin,
              destination,
              service.carrier,
              service.name,
              service_code: service.service_code,
              total_price: total.cents,
              currency: total.currency.to_s
            )
          end.compact
        )
      end
    end
  end
end
