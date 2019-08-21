require 'test_helper'

module Workarea
  class Payment
    class CaptureTest < TestCase
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

      def test_invalid_if_an_amount_exceeds_the_tenders_authorized_amount
        capture = Capture.new(
          payment: payment,
          amounts: { payment.credit_card.id => 100.to_m }
        )

        refute(capture.valid?)
        assert(capture.errors[:credit_card].present?)
      end

      def test_invalid_if_the_amount_exceeds_the_tenders_capturable_amount
        auth = payment.credit_card.build_transaction(
          action: 'authorize',
          amount: 5.to_m
        )
        auth.complete!

        payment
          .credit_card
          .build_transaction(action: 'capture', amount: 3.to_m, reference: auth)
          .complete!

        capture = Capture.new(
          payment: payment,
          amounts: { payment.credit_card.id => 5.to_m }
        )

        refute(capture.valid?)
        assert(capture.errors[:credit_card].present?)
      end

      def test_builds_a_transaction_for_each_authorization
        payment.adjust_tender_amounts(5.to_m)

        payment
          .credit_card
          .build_transaction(action: 'authorize', amount: 3.to_m)
          .complete!
        payment
          .credit_card
          .build_transaction(action: 'authorize', amount: 2.to_m)
          .complete!
        payment
          .credit_card
          .build_transaction(action: 'authorize', amount: 2.to_m)
          .tap(&:complete!)
          .tap(&:cancel!)

        capture = Capture.new(
          payment: payment,
          amounts: { payment.credit_card.id => 5.to_m }
        )

        assert_equal(2, capture.transactions.length)
        assert_equal(payment.credit_card, capture.transactions.first.tender)
        assert_equal(2.to_m, capture.transactions.first.amount)
        assert_equal(payment.credit_card, capture.transactions.second.tender)
        assert_equal(3.to_m, capture.transactions.second.amount)
      end

      def test_builds_the_correct_number_for_a_non_complete_refund
        payment.adjust_tender_amounts(11.to_m)
        payment
          .credit_card
          .build_transaction(action: 'authorize', amount: 3.to_m)
          .complete!
        payment
          .credit_card
          .build_transaction(action: 'authorize', amount: 2.to_m)
          .complete!

        capture = Capture.new(
          payment: payment,
          amounts: {
            payment.credit_card.id => 2.to_m
          }
        )

        assert_equal(1, capture.transactions.length)
        assert_equal(payment.credit_card, capture.transactions.first.tender)
        assert_equal(2.to_m, capture.transactions.first.amount)
      end

      def test_does_not_perform_the_operation_if_not_valid
        capture = Capture.new(
          payment: payment,
          amounts: { payment.credit_card.id => 100.to_m }
        )

        capture.complete!

        assert(capture.new_record?)
        assert(capture.result_transaction_ids.empty?)
      end

      def test_allocate_amounts
        payment.adjust_tender_amounts(11.to_m)

        # Store credit does a purchase on authorization. For the purpose
        # of testing allocation we are updating the transaction back to an
        # authorize.
        payment
          .store_credit
          .build_transaction(action: 'authorize', amount: 6.to_m)
          .tap(&:complete!)
          .update!(action: 'authorize')

        payment
          .credit_card
          .build_transaction(action: 'authorize', amount: 5.to_m)
          .complete!

        capture = Capture.new(payment: payment)
        capture.allocate_amounts!(total: 11.to_m)
        assert_equal(2, capture.amounts.size)
        assert_equal(6.to_m, capture.amounts[payment.store_credit.id])
        assert_equal(5.to_m, capture.amounts[payment.credit_card.id])

        capture.allocate_amounts!(total: 7.to_m)
        assert_equal(2, capture.amounts.size)
        assert_equal(6.to_m, capture.amounts[payment.store_credit.id])
        assert_equal(1.to_m, capture.amounts[payment.credit_card.id])

        capture.allocate_amounts!(total: 3.to_m)
        assert_equal(2, capture.amounts.size)
        assert_equal(3.to_m, capture.amounts[payment.store_credit.id])
        assert_equal(0.to_m, capture.amounts[payment.credit_card.id])
      end
    end
  end
end
