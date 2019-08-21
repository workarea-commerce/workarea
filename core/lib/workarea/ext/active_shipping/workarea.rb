module ActiveShipping
  class Workarea < ActiveShipping::Carrier
    def find_rates(*args)
      ::Workarea::Shipping::RateLookup.new(*args).response
    end
  end
end
