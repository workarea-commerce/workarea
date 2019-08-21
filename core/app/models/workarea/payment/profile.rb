module Workarea
  class Payment
    class Profile
      include ApplicationDocument

      field :email, type: String
      field :reference, type: String
      field :gateway_id, type: String
      field :store_credit, type: Money, default: 0

      has_many :credit_cards, class_name: 'Workarea::Payment::SavedCreditCard'

      validates :email, presence: true
      validates :reference, presence: true, uniqueness: true

      index({ email: 1, reference: 1 }, { unique: true })
      index({ reference: 1 }, { unique: true })

      def self.lookup(reference)
        find_by(reference: reference.id)
      rescue Mongoid::Errors::DocumentNotFound
        create!(reference: reference.id) do |profile|
          profile.email = reference.email
        end
      end

      def self.update_email(reference, new_email)
        lookup(reference).update_attribute(:email, new_email)
      end

      # Finds the default saved credit card for a user.
      #
      # @return [SavedCreditCard]
      #
      def default_credit_card
        credit_cards.find_by(default: true)
      rescue
        credit_cards.desc(:created_at).first
      end

      # Use store credit to make a purchase
      #
      # @params [Integer] cents
      #
      def purchase_on_store_credit(cents)
        raise InsufficientFunds if store_credit.cents < cents
        inc('store_credit.cents' => 0 - cents)
      end

      # Reload store credit to refund a purchase
      #
      # @params [Integer] cents
      #
      def reload_store_credit(cents)
        inc('store_credit.cents' => cents)
      end
    end
  end
end
