module Workarea
  module Admin
    module CreditCardsHelper
      def credit_card_issuer_icon(issuer)
        icon_path = if card_icon_available?(issuer)
                      "workarea/admin/payment_icons/#{issuer.systemize}.svg"
                    else
                      'workarea/admin/default_card.svg'
                    end

        inline_svg_tag(icon_path, class: "payment-icon payment-icon--#{issuer.dasherize}", title: issuer.humanize)
      end

      def card_icon_name(issuer)
        issuer.parameterize.underscore
      end

      private

      def card_icon_available?(issuer)
        return false if issuer == 'test_card'
        Workarea.config.credit_card_issuers.values.any? { |s| s.optionize == issuer }
      end
    end
  end
end
