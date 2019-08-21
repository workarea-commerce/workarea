require 'test_helper'

module Workarea
  class Payment
    class Tender
      class StoreCreditTest < TestCase
        def test_amount=
          profile = create_payment_profile(store_credit: 5.to_m)
          payment = create_payment(profile: profile)
          tender = payment.build_store_credit

          tender.amount = 10.to_m
          assert_equal(5.to_m, tender.amount)
        end
      end
    end
  end
end
