module Workarea
  class Payment
    class Tender
      class CreditCard < Tender
        include Payment::CreditCard

        field :saved_card_id, type: String

        delegate :profile, :first_name, :last_name, to: :payment, allow_nil: true

        before_validation :set_saved_card_values

        def saved?
          saved_card_id.present?
        end

        def tokenized?
          super || saved?
        end

        def saved_card
          @saved_card ||= profile.credit_cards.find(saved_card_id) if saved?
        rescue
          nil
        end

        def slug
          :credit_card
        end

        def to_token_or_active_merchant
          token.presence || to_active_merchant
        end

        private

        def set_saved_card_values
          if saved_card.present?
            self.display_number = saved_card.display_number
            self.issuer = saved_card.issuer
            self.month = saved_card.month
            self.year = saved_card.year
            self.token = saved_card.token
          end
        end
      end
    end
  end
end
