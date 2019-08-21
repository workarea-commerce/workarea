require 'test_helper'

module Workarea
  class Payment
    class SavedCreditCardTest < TestCase
      def test_save
        card = SavedCreditCard.new(
          profile: create_payment_profile(reference: '234'),
          number: '1',
          cvv: '123',
          month: 12,
          year: Time.current.year + 1,
          first_name: 'Robert',
          last_name: 'Clams'
        )

        card.save
        assert(card.tokenized?)

        profile = create_payment_profile
        current_default = create_saved_credit_card(profile: profile, default: true)
        new_default = create_saved_credit_card(profile: profile, default: true)

        current_default.reload
        new_default.reload

        refute(current_default.default?)
        assert(new_default.default?)
      end
    end
  end
end
