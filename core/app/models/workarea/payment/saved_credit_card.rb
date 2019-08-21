module Workarea
  class Payment
    class SavedCreditCard
      include ApplicationDocument
      include Payment::CreditCard

      field :first_name, type: String
      field :last_name, type: String
      field :default, type: Boolean, default: false

      belongs_to :profile, class_name: 'Workarea::Payment::Profile', index: true
      index({ profile_id: 1, created_at: 1 })

      before_validation :ensure_tokenized
      after_save :update_default

      validate :token_set

      private

      def ensure_tokenized
        return if tokenized?
        StoreCreditCard.new(self).perform! if !persisted? || card_change?
      end

      def token_set
        return true if token.present?

        errors.add(:base, I18n.t('workarea.payment.store_credit_card_failure'))
      end

      def update_default
        return unless default?

        profile
          .credit_cards
          .where(default: true)
          .excludes(id: id)
          .update_all(default: false)
      end
    end
  end
end
