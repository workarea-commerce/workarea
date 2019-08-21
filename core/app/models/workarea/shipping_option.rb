module Workarea
  class ShippingOption
    include GuardNegativePrice

    attr_reader :carrier, :name, :service_code, :tax_code
    attr_writer :price_adjustments

    def self.from_rate_estimate(rate)
      new(
        carrier: rate.carrier,
        name: rate.service_name,
        service_code: rate.service_code,
        price: Money.new(rate.price, rate.currency),
        tax_code: Shipping::Service.find_tax_code(
          rate.carrier,
          rate.service_name
        )
      )
    end

    def initialize(attributes = {})
      @attributes = attributes.with_indifferent_access
      attributes.each do |name, value|
        instance_variable_set("@#{name}", value)
      end
    end

    def base_price
      (@price || 0).to_m
    end

    def price_adjustments
      @price_adjustments || []
    end

    def price
      guard_negative_price do
        base_price + price_adjustments.map(&:amount).sum.to_m
      end
    end

    def to_h
      {
        carrier: carrier,
        name: name,
        service_code: service_code,
        price: price,
        base_price: base_price,
        tax_code: tax_code
      }
    end
  end
end
