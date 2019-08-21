require 'test_helper'

module Workarea
  module Storefront
    class UserViewModelTest < TestCase
      def test_has_default_addresses
        user = User.new
        view_model = Storefront::UserViewModel.new(user)
        refute(view_model.has_default_addresses?)

        user.addresses.build
        assert(view_model.has_default_addresses?)
      end

      def test_default_credit_card_gets_the_default_card_from_payment
        user = create_user
        profile = Payment::Profile.lookup(PaymentReference.new(user))
        card = create_saved_credit_card(profile: profile)

        view_model = Storefront::UserViewModel.new(user)
        assert_equal(card, view_model.default_credit_card)
      end

      def test_email_signup
        user = create_user

        Email.signup(user.email)
        assert(UserViewModel.wrap(user).email_signup?)

        Email.unsignup(user.email)
        refute(UserViewModel.wrap(user).email_signup?)
      end
    end
  end
end
