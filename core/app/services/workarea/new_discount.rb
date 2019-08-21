module Workarea
  module NewDiscount
    def self.new_discount(type, attributes)
      return nil unless valid_class?(type)

      klass = "Workarea::Pricing::Discount::#{type.to_s.classify}".constantize
      klass.new(attributes)
    end

    def self.valid_class?(type)
      return false if type.to_s.blank?

      discount_class = type.to_s.demodulize.classify
      !!"Workarea::Pricing::Discount::#{discount_class}".constantize rescue false
    end
  end
end
