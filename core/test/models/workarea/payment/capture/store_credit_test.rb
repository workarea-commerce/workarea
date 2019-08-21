require 'test_helper'

module Workarea
  class Payment
    class Capture
      class StoreCreditTest < TestCase
        def profile
          @profile ||= create_payment_profile(store_credit: 15.to_m)
        end

        def payment
          @payment ||= create_payment(profile: profile)
        end

        def tender
          @tender ||= begin
            payment.set_store_credit
            payment.store_credit
          end
        end

        def test_complete!
          transaction = tender.build_transaction(amount: 5.to_m)
          operation = StoreCredit.new(tender, transaction)

          operation.complete!

          assert(transaction.success?)
          assert_equal(
            ActiveMerchant::Billing::Response,
            transaction.response.class
          )
        end

        def test_cancel!
          transaction = tender.build_transaction(amount: 5.to_m)
          operation = StoreCredit.new(tender, transaction)

          operation.cancel!

          assert(transaction.success?)
          assert_equal(
            ActiveMerchant::Billing::Response,
            transaction.response.class
          )
        end
      end
    end
  end
end
