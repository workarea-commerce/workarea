module Workarea
  module Storefront
    module Checkout
      class ConfirmationViewModel < ApplicationViewModel
        include CheckoutContent

        def title
          browser_title.presence ||
            ::I18n.t('workarea.storefront.checkouts.confirmation_title')
        end
      end
    end
  end
end
