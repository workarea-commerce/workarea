require 'test_helper'

module Workarea
  class Payment
    class Tender
      class CreditCardTest < TestCase
        def profile
          @profile ||= create_payment_profile
        end

        def payment
          @payment ||= create_payment(profile: profile)
        end

        def saved_card
          @saved_card ||= create_saved_credit_card(profile: profile)
        end

        def tender
          @tender ||= CreditCard.new(payment: payment, saved_card_id: saved_card.id)
        end

        def test_valid?
          tender.valid?

          assert_equal(saved_card.display_number, tender.display_number)
          assert_equal(saved_card.issuer, tender.issuer)
          assert_equal(saved_card.month, tender.month)
          assert_equal(saved_card.year, tender.year)
          assert_equal(saved_card.token, tender.token)

          saved_card.delete
          assert_nothing_raised { tender.valid? }
        end

        def test_saved?
          assert(tender.saved?)

          tender.saved_card_id = nil
          refute(tender.saved?)
        end

        def test_tokenized?
          assert(tender.tokenized?)

          tender.saved_card_id = nil
          refute(tender.tokenized?)
        end
      end
    end
  end
end
