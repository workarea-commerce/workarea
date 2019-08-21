module Workarea
  class User
    class SavedAddress < Address
      field :last_shipped_at, type: Time
      field :last_billed_at, type: Time

      def allow_po_box?
        Workarea.config.allow_shipping_address_po_box ||
          Workarea.config.allow_payment_address_po_box
      end
    end
  end
end
