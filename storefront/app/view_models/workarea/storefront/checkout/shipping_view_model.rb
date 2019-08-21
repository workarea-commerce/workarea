module Workarea
  module Storefront
    class Checkout::ShippingViewModel < ApplicationViewModel
      include CheckoutContent

      delegate :shipping_service, to: :shipping

      def shipping_address
        shipping.try(:address)
      end
    end
  end
end
