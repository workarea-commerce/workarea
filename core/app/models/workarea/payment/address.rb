module Workarea
  class Payment
    class Address < Workarea::Address
      def allow_po_box?
        Workarea.config.allow_payment_address_po_box
      end
    end
  end
end
