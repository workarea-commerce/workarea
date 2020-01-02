require 'test_helper'

module Workarea
  module Storefront
    class CreditCardsHelperTest < ViewTest
      include InlineSvg::ActionView::Helpers

      def test_credit_card_issuer_icon
        assert_equal(
          inline_svg_tag(
            'workarea/storefront/default_card.svg',
            class: 'payment-icon payment-icon--foo',
            title: 'Foo'
          ),
          credit_card_issuer_icon('Foo')
        )

        assert_equal(
          inline_svg_tag(
            'workarea/storefront/payment_icons/visa.svg',
            class: 'payment-icon payment-icon--visa',
            title: 'Visa'
          ),
          credit_card_issuer_icon('Visa')
        )
      end
    end
  end
end
