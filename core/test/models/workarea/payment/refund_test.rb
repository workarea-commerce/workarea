require 'test_helper'

module Workarea
  class Payment
    class RefundTest < Workarea::TestCase
      setup :setup_payment

      def profile
        @profile ||= create_payment_profile(store_credit: 6.to_m)
      end

      def payment
        @payment ||= create_payment(profile: profile)
      end

      def setup_payment
        payment.set_address(
          first_name: 'Ben',
          last_name: 'Crouse',
          street: '22 S. 3rd St.',
          city: 'Philadelphia',
          region: 'PA',
          postal_code: '19106',
          country: 'US',
          phone_number: '2159251800'
        )

        payment.set_store_credit
        payment.set_credit_card(
          number: '1',
          month: 1,
          year: Time.current.year + 1,
          cvv: '999',
          amount: 5.to_m
        )
      end

      def test_valid_is_false_if_an_amount_exceeds_the_tenders_captured_amount
        payment.purchase!
        refund = Refund.new(
          payment: payment,
          amounts: { payment.store_credit.id => 7.to_m }
        )

        refute(refund.valid?)
        assert(refund.errors[:store_credit].present?)
      end

      def test_valid_is_false_if_the_amount_exceeds_the_tenders_refundable_amount
        auth = payment
                .credit_card
                .build_transaction(action: 'authorize', amount: 5.to_m)

        auth.complete!

        payment
          .credit_card
          .build_transaction(action: 'capture', amount: 3.to_m, reference: auth)
          .complete!
        payment
          .credit_card
          .build_transaction(action: 'refund', amount: 1.to_m, reference: auth)
          .complete!

        refund = Refund.new(
          payment: payment,
          amounts: { payment.credit_card.id => 5.to_m }
        )

        refute(refund.valid?)
        assert(refund.errors[:credit_card].present?)
      end

      def test_transactions_builds_a_transaction_for_each_capture
        payment.adjust_tender_amounts(11.to_m)
        payment.authorize!

        auth = payment.credit_card.transactions.first
        payment
          .store_credit
          .build_transaction(action: 'capture', amount: 6.to_m)
          .complete!
        payment
          .credit_card
          .build_transaction(action: 'capture', amount: 3.to_m, reference: auth)
          .complete!
        payment
          .credit_card
          .build_transaction(action: 'capture', amount: 2.to_m, reference: auth)
          .complete!
        payment
          .credit_card
          .build_transaction(action: 'capture', amount: 2.to_m, reference: auth)
          .tap(&:complete!)
          .tap(&:cancel!)


        refund = Refund.new(
          payment: payment,
          amounts: {
            payment.store_credit.id => 6.to_m,
            payment.credit_card.id => 5.to_m
          }
        )

        assert_equal(3, refund.transactions.length)
        assert_equal(payment.store_credit, refund.transactions.first.tender)
        assert_equal(6.to_m, refund.transactions.first.amount)
        assert_equal(payment.credit_card, refund.transactions.second.tender)
        assert_equal(2.to_m, refund.transactions.second.amount)
        assert_equal(payment.credit_card, refund.transactions.third.tender)
        assert_equal(3.to_m, refund.transactions.third.amount)
      end

      def test_transactions_builds_the_correct_number_for_a_non_complete_refund
        payment.adjust_tender_amounts(11.to_m)
        payment.authorize!

        auth = payment.credit_card.transactions.first

        payment
          .credit_card
          .build_transaction(action: 'capture', amount: 3.to_m, reference: auth)
          .complete!
        payment
          .credit_card
          .build_transaction(action: 'capture', amount: 2.to_m, reference: auth)
          .complete!

        refund = Refund.new(
          payment: payment,
          amounts: {
            payment.credit_card.id => 2.to_m
          }
        )

        assert_equal(1, refund.transactions.length)
        assert_equal(payment.credit_card, refund.transactions.first.tender)
        assert_equal(2.to_m, refund.transactions.first.amount)
      end

      def test_complete_does_not_perform_the_operation_if_not_valid
        payment.purchase!

        refund = Refund.new(
          payment: payment,
          amounts: { payment.store_credit.id => 7.to_m }
        )

        refund.complete!

        assert(refund.new_record?)
        assert(refund.result_transaction_ids.empty?)
      end

      def test_allocate_amounts
        payment.authorize!

        auth = payment.credit_card.transactions.first
        payment
          .store_credit
          .build_transaction(action: 'capture', amount: 6.to_m)
          .complete!
        payment
          .credit_card
          .build_transaction(action: 'capture', amount: 5.to_m, reference: auth)
          .complete!

        refund = Refund.new(payment: payment)

        refund.allocate_amounts!(total: 11.to_m)
        assert_equal(2, refund.amounts.size)
        assert_equal(5.to_m, refund.amounts[payment.credit_card.id])
        assert_equal(6.to_m, refund.amounts[payment.store_credit.id])

        refund.allocate_amounts!(total: 7.to_m)
        assert_equal(2, refund.amounts.size)
        assert_equal(5.to_m, refund.amounts[payment.credit_card.id])
        assert_equal(2.to_m, refund.amounts[payment.store_credit.id])

        refund.allocate_amounts!(total: 3.to_m)
        assert_equal(2, refund.amounts.size)
        assert_equal(3.to_m, refund.amounts[payment.credit_card.id])
        assert_equal(0.to_m, refund.amounts[payment.store_credit.id])
      end
    end
  end
end
