require 'test_helper'

module Workarea
  module Storefront
    module Checkout
      class PaymentViewModelTest < TestCase
        setup :set_checkout

        def set_checkout
          @order = Order.new(email: 'bcrouse@workarea.com')
          @user = User.new(email: 'bcrouse@workarea.com')
        end

        def test_credit_cards_returns_credit_cards_wrapped_in_view_model
          profile = Payment::Profile.lookup(PaymentReference.new(@user))
          2.times { create_saved_credit_card(profile: profile) }

          checkout = Workarea::Checkout.new(@order, @user)
          checkout.payment.update_attributes!(profile_id: profile.id)
          view_model = PaymentViewModel.new(checkout)

          assert_equal(2, view_model.credit_cards.length)
          view_model.credit_cards.each do |card|
            assert_instance_of(CreditCardViewModel, card)
          end
        end

        def test_credit_cards_does_not_return_credit_cards_if_the_user_is_not_present
          profile = Payment::Profile.lookup(PaymentReference.new(@user))
          2.times { create_saved_credit_card(profile: profile) }

          checkout = Workarea::Checkout.new(@order)
          checkout.payment.update_attributes!(profile_id: profile.id)
          view_model = PaymentViewModel.new(checkout)
          assert(view_model.credit_cards.empty?)
        end

        def test_order_covered_by_store_credit
          reference = PaymentReference.new(@user, @order)
          profile = create_payment_profile(
            email: reference.email,
            reference: reference.id,
            store_credit: 10.to_m
          )

          checkout = Workarea::Checkout.new(@order, @user)
          checkout.payment.update_attributes!(profile_id: profile.id)

          @order.total_price = 5
          assert(PaymentViewModel.new(checkout).order_covered_by_store_credit?)

          @order.total_price = 10
          assert(PaymentViewModel.new(checkout).order_covered_by_store_credit?)

          @order.total_price = 11
          refute(PaymentViewModel.new(checkout).order_covered_by_store_credit?)
        end

        def test_using_new_card
          @order.total_price = 100

          profile = Payment::Profile.lookup(PaymentReference.new(@user))
          checkout = Workarea::Checkout.new(@order, @user)
          checkout.payment.update_attributes!(profile_id: profile.id)
          credit_card = create_saved_credit_card(profile: profile)

          view_model = PaymentViewModel.new(checkout, payment: 'not found')
          assert(view_model.using_new_card?)

          view_model = PaymentViewModel.new(checkout, payment: credit_card.id)
          refute(view_model.using_new_card?)
        end
      end
    end
  end
end
