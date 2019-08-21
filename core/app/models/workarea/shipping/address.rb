module Workarea
  class Shipping
    class Address < Workarea::Address
      def reset
        Workarea.config.address_attributes.each { |name| send("#{name}=", nil) }
      end

      def to_active_shipping
        ActiveShipping::Location.new(
          country: country.alpha2,
          state: region,
          city: city,
          zip: postal_code
        )
      end

      def allow_po_box?
        Workarea.config.allow_shipping_address_po_box
      end
    end
  end
end
