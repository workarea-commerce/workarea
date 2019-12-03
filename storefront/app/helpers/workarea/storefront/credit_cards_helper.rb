module Workarea
  module Storefront
    module CreditCardsHelper
      def credit_card_issuer_icon(issuer)
        icon_path = if card_icon_available?(issuer.optionize)
                      "workarea/storefront/payment_icons/#{issuer.systemize}.svg"
                    else
                      'workarea/storefront/default_card.svg'
                    end

        inline_svg_tag(icon_path, class: "payment-icon payment-icon--#{issuer.downcase.dasherize}", title: issuer.humanize)
      end

      def card_icon_name(issuer)
        issuer.parameterize.underscore
      end

      def all_payment_icons
        icons = credit_card_issuers.reduce('') do |memo, issuer|
          memo + credit_card_issuer_icon(issuer.optionize)
        end

        icons.html_safe
      end

      private

      def credit_card_issuers
        Workarea.config.credit_card_issuers.values
      end

      def card_icon_available?(issuer)
        return false if issuer == 'test_card'
        credit_card_issuers.any? { |s| s.optionize == issuer }
      end
    end
  end
end
