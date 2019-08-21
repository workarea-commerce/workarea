require 'test_helper'

module Workarea
  class Payment
    class TenderTest < TestCase
      setup :set_tender

      def set_tender
        @tender = Tender.new(payment: create_payment)
      end

      def test_authorized_amount_is_the_sum_of_the_successful_auth_amounts
        @tender
          .build_transaction(action: 'authorize', amount: 6.to_m)
          .update_attributes!(success: false)
        @tender
          .build_transaction(action: 'authorize', amount: 6.to_m)
          .update_attributes!(success: true)
        @tender
          .build_transaction(action: 'purchase', amount: 7.to_m)
          .update_attributes!(success: true)
        @tender
          .build_transaction(action: 'capture', amount: 5.to_m)
          .update_attributes!(success: false)
        @tender
          .build_transaction(action: 'capture', amount: 6.to_m)
          .update_attributes!(success: true)
        @tender
          .build_transaction(action: 'capture', amount: 7.to_m)
          .update_attributes!(success: true)
        @tender
          .build_transaction(action: 'capture', amount: 7.to_m)
          .update_attributes!(success: true, canceled_at: Time.current)

        assert_equal(6.to_m, @tender.authorized_amount)
      end

      def test_captured_amount_is_the_sum_of_the_successful_capture_amounts
        @tender
          .build_transaction(action: 'authorize', amount: 6.to_m)
          .update_attributes!(success: true)
        @tender
          .build_transaction(action: 'purchase', amount: 7.to_m)
          .update_attributes!(success: true)
        @tender
          .build_transaction(action: 'capture', amount: 5.to_m)
          .update_attributes!(success: false)
        @tender
          .build_transaction(action: 'capture', amount: 6.to_m)
          .update_attributes!(success: true)
        @tender
          .build_transaction(action: 'capture', amount: 7.to_m)
          .update_attributes!(success: true)
        @tender
          .build_transaction(action: 'capture', amount: 7.to_m)
          .update_attributes!(success: true, canceled_at: Time.current)

        assert_equal(20.to_m, @tender.captured_amount)
      end

      def test_uncaptured_amount_is_the_authed_amount_less_the_captured_amount
        @tender
          .build_transaction(action: 'authorize', amount: 10.to_m)
          .update_attributes!(success: true)
        @tender
          .build_transaction(action: 'purchase', amount: 7.to_m)
          .update_attributes!(success: true)
        @tender
          .build_transaction(action: 'capture', amount: 1.to_m)
          .update_attributes!(success: false)
        @tender
          .build_transaction(action: 'capture', amount: 2.to_m)
          .update_attributes!(success: true)

        assert_equal(8.to_m, @tender.uncaptured_amount)
      end

      def test_refunded_amount_is_the_sum_of_the_successful_capture_amounts
        @tender
          .build_transaction(action: 'authorize', amount: 6.to_m)
          .update_attributes!(success: true)
        @tender
          .build_transaction(action: 'purchase', amount: 7.to_m)
          .update_attributes!(success: true)
        @tender
          .build_transaction(action: 'capture', amount: 5.to_m)
          .update_attributes!(success: false)
        @tender
          .build_transaction(action: 'refund', amount: 6.to_m)
          .update_attributes!(success: false)
        @tender
          .build_transaction(action: 'refund', amount: 7.to_m)
          .update_attributes!(success: true)
        @tender
          .build_transaction(action: 'refund', amount: 7.to_m)
          .update_attributes!(success: true, canceled_at: Time.current)

        assert_equal(7.to_m, @tender.captured_amount)
      end

      def test_capturable_amount_is_the_authorized_amount_less_the_captured_amount
        @tender
          .build_transaction(action: 'authorize', amount: 6.to_m)
          .update_attributes!(success: false)
        @tender
          .build_transaction(action: 'authorize', amount: 6.to_m)
          .update_attributes!(success: true)
        @tender
          .build_transaction(action: 'capture', amount: 5.to_m)
          .update_attributes!(success: false)
        @tender
          .build_transaction(action: 'capture', amount: 5.to_m)
          .update_attributes!(success: true)
        @tender
          .build_transaction(action: 'capture', amount: 5.to_m)
          .update_attributes!(success: true, canceled_at: Time.current)

        assert_equal(1.to_m, @tender.capturable_amount)
      end

      def test_capturable_amount_cannot_be_negative
        @tender
          .build_transaction(action: 'authorize', amount: 6.to_m)
          .update_attributes!(success: false)
        @tender
          .build_transaction(action: 'authorize', amount: 6.to_m)
          .update_attributes!(success: true)
        @tender
          .build_transaction(action: 'purchase', amount: 7.to_m)
          .update_attributes!(success: true)
        @tender
          .build_transaction(action: 'capture', amount: 5.to_m)
          .update_attributes!(success: false)
        @tender
          .build_transaction(action: 'capture', amount: 5.to_m)
          .update_attributes!(success: true)

        assert_equal(0.to_m, @tender.capturable_amount)
      end

      def test_refundable_amount_is_the_authorized_amount_less_the_captured_amount
        @tender
          .build_transaction(action: 'authorize', amount: 6.to_m)
          .update_attributes!(success: false)
        @tender
          .build_transaction(action: 'authorize', amount: 6.to_m)
          .update_attributes!(success: true)
        @tender
          .build_transaction(action: 'capture', amount: 5.to_m)
          .update_attributes!(success: false)
        @tender
          .build_transaction(action: 'capture', amount: 5.to_m)
          .update_attributes!(success: true)
        @tender
          .build_transaction(action: 'refund', amount: 3.to_m)
          .update_attributes!(success: false)
        @tender
          .build_transaction(action: 'refund', amount: 3.to_m)
          .update_attributes!(success: true)
        @tender
          .build_transaction(action: 'refund', amount: 3.to_m)
          .update_attributes!(success: true, canceled_at: Time.current)

        assert_equal(2.to_m, @tender.refundable_amount)
      end

      def test_refundable_amount_cannot_be_negative
        @tender
          .build_transaction(action: 'authorize', amount: 6.to_m)
          .update_attributes!(success: false)
        @tender
          .build_transaction(action: 'authorize', amount: 6.to_m)
          .update_attributes!(success: true)
        @tender
          .build_transaction(action: 'purchase', amount: 7.to_m)
          .update_attributes!(success: true)
        @tender
          .build_transaction(action: 'capture', amount: 5.to_m)
          .update_attributes!(success: false)
        @tender
          .build_transaction(action: 'capture', amount: 5.to_m)
          .update_attributes!(success: true)
        @tender
          .build_transaction(action: 'refund', amount: 15.to_m)
          .update_attributes!(success: true)

        assert_equal(0.to_m, @tender.capturable_amount)
      end
    end
  end
end
