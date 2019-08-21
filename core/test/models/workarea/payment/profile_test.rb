require 'test_helper'

module Workarea
  class Payment
    class ProfileTest < TestCase
      def reference
        @reference ||= PaymentReference.new(create_user)
      end

      def profile
        @profile ||= Profile.lookup(reference)
      end

      def test_default_credit_card
        default = create_saved_credit_card(profile: profile, default: true)
        create_saved_credit_card(profile: profile, default: false)
        assert_equal(default, profile.default_credit_card)

        profile.credit_cards = []
        default = create_saved_credit_card(profile: profile)
        create_saved_credit_card(profile: profile, created_at: Time.current - 1.hour)
        assert_equal(default, profile.default_credit_card)
      end

      def test_purchase_on_store_credit
        profile.update_attributes(store_credit: 10.to_m)

        profile.purchase_on_store_credit(500)
        profile.reload

        assert_equal(5.to_m, profile.store_credit)

        assert_raises(InsufficientFunds) do
          profile.purchase_on_store_credit(5000)
        end
      end

      def test_reload_store_credit
        profile.update_attributes(store_credit: 0.to_m)

        profile.reload_store_credit(500)
        profile.reload

        assert_equal(5.to_m, profile.store_credit)
      end
    end
  end
end
