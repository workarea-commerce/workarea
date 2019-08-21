require 'test_helper'

module Workarea
  class Payment
    module Purchase
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
          profile.reload

          assert_equal(10.to_m, profile.store_credit)
          assert(transaction.success?)
          assert_equal(
            ActiveMerchant::Billing::Response,
            transaction.response.class
          )

          transaction = tender.build_transaction(amount: 100.to_m)
          operation = StoreCredit.new(tender, transaction)

          operation.complete!
          refute(transaction.success?)
          assert(transaction.response)
          assert_equal(
            ActiveMerchant::Billing::Response,
            transaction.response.class
          )
        end

        def test_cancel!
          transaction = tender.build_transaction(amount: 5.to_m, success: false)
          operation = StoreCredit.new(tender, transaction)

          operation.cancel!
          profile.reload

          assert_equal(15.to_m, profile.store_credit)

          transaction = tender.build_transaction(amount: 5.to_m, success: true)
          operation = StoreCredit.new(tender, transaction)

          operation.cancel!
          profile.reload

          assert_equal(20.to_m, profile.store_credit)
          assert_equal(
            ActiveMerchant::Billing::Response,
            transaction.cancellation.class
          )
        end
      end
    end
  end
end
