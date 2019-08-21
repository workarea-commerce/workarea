module Workarea
  class Payment
    module CreditCard
      extend ActiveSupport::Concern

      included do
        field :issuer, type: String
        field :display_number,type: String
        field :month, type: Integer
        field :year, type: Integer
        field :token, type: String

        attr_reader :number, :cvv
        attr_writer :cvv

        validate :number_presence
        validate :valid_number
        validate :cvv_presence
        validate :not_expired
        validate :issuer_accepted

        validates :first_name, presence: true
        validates :last_name, presence: true
        validates :cvv, numericality: { only_integer: true, allow_blank: true }
        validates :year, presence: true, numericality: { only_integer: true }
        validates :month, presence: true, numericality: {
          greater_than_or_equal_to: 1,
          less_than_or_equal_to: 12,
          only_integer: true
        }

        before_validation :set_display_number
        before_validation :set_issuer

        delegate :email, to: :profile
      end

      def number=(val)
        @number = val.to_s.gsub(/\D/, '')
      end

      def expired?
        Time.current > Time.zone.parse("#{month}/#{year}").next_month.beginning_of_month
      end

      def number_changed?
        number.present? && number.to_s.last(4) != display_number.to_s.last(4)
      end

      def card_change?
        persisted? && (number_changed? || month_changed? || year_changed?)
      end

      def tokenized?
        token.present?
      end

      def to_active_merchant
        ActiveMerchant::Billing::CreditCard.new(
          # TODO token doesn't make sense here because ActiveMerchant::CreditCard
          # strips anything that's not a number and most tokens are alpha numberic
          number: token.presence || number.presence || display_number,
          month: month,
          year: year,
          verification_value: cvv,
          first_name: first_name,
          last_name: last_name
        )
      end

      private

      def set_display_number
        if number.present?
          self.display_number = ActiveMerchant::Billing::CreditCard.mask(number)
        end
      end

      def set_issuer
        if number.present?
          brand = ActiveMerchant::Billing::CreditCard.brand?(number)

          if brand.present?
            self.issuer = Workarea.config.credit_card_issuers[brand].to_s
          end
        end
      end

      def issuer_accepted
        unless Workarea.config.credit_card_issuers.value?(issuer)
          message = I18n.t(
            'workarea.errors.messages.invalid_credit_card_issuer',
            value: issuer,
            issuers: Workarea.config.credit_card_issuers.values.to_sentence
          )
          errors.add(:base, message)
        end
      end

      def number_presence
        if !tokenized? && number.blank?
          errors.add(:number, I18n.t('errors.messages.blank'))
        end
      end

      def cvv_presence
        if (!tokenized? || card_change?) && cvv.blank?
          errors.add(:cvv, I18n.t('errors.messages.blank'))
        end
      end

      def valid_number
        if number.present? && !ActiveMerchant::Billing::CreditCard.valid_number?(number)
          errors.add(
            :number,
            I18n.t('workarea.errors.messages.invalid_credit_card_number')
          )
        end
      end

      def not_expired
        return unless month.present? && year.present?
        if expired?
          errors.add(
            :expiration_date,
            I18n.t('workarea.errors.messages.expired_date')
          )
        end
      end
    end
  end
end
