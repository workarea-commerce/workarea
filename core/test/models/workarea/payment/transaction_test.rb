require 'test_helper'

module Workarea
  class Payment
    class TransactionTest < TestCase
      setup :setup_classes
      teardown :remove_classes

      def setup_classes
        Workarea::Payment::Tender.const_set(
          'Foo',
          Class.new(Workarea::Payment::Tender)
        )

        Workarea::Payment::Authorize.const_set(
          'Foo',
          Class.new do
            include OperationImplementation

            def complete!
              response = ActiveMerchant::Billing::Response.new(true, 'Authorized')
              transaction.response = response
            end

            def cancel!
              response = ActiveMerchant::Billing::Response.new(true, 'Canceled')
              transaction.cancellation = response
            end
          end
        )

        Workarea::Payment::Capture.const_set(
          'Foo',
          Class.new do
            include OperationImplementation

            def complete!
              validate_reference!
            end

            def cancel!
            end
          end
        )
      end

      def remove_classes
        Tender.send(:remove_const, :Foo)
        Authorize.send(:remove_const, :Foo)
        Capture.send(:remove_const, :Foo)
      end

      def tender
        @tender ||= Tender::Foo.new(payment: create_payment)
      end

      def test_complete!
        transaction = tender.build_transaction(action: 'authorize', amount: 5)
        transaction.complete!

        assert(transaction.success)
        assert_equal('Authorized', transaction.message)
      end

      def test_cancel!
        transaction = tender.build_transaction(action: 'authorize', amount: 5)
        transaction.cancel!

        assert(transaction.canceled?)
        assert_equal(
          ActiveMerchant::Billing::Response,
          transaction.cancellation.class
        )
      end

      def test_captured_amount
        transaction = tender.build_transaction(action: 'authorize', amount: 5)

        2.times do
          tender
            .build_transaction(
              action: 'capture',
              amount: 1,
              success: true,
              reference: transaction
            )
            .save!
        end

        assert_equal(2.to_m, transaction.captured_amount)
      end

      def test_captured_amount_on_purchase
        transaction = tender.build_transaction(action: 'purchase', amount: 5)
        assert_equal(5.to_m, transaction.captured_amount)
      end

      def test_captured_amount_after_catpures
        transaction = tender.build_transaction(action: 'capture', amount: 5)
        assert_equal(5.to_m, transaction.captured_amount)

        tender.build_transaction(
          action: 'capture',
          amount: 5,
          canceled_at: Time.current
        )

        assert_equal(5.to_m, transaction.captured_amount)
      end

      def test_message
        response = ActiveMerchant::Billing::Response.new(true, 'Message')
        transaction = Transaction.new(response: response)
        assert_equal('Message', transaction.message)

        response = ActiveMerchant::Billing::Response.new(false, 'Message')
        transaction = Transaction.new(response: response)
        assert_equal('There was a problem processing your payment. Message', transaction.message)

        response = ActiveMerchant::Billing::Response.new(false, nil)
        transaction = Transaction.new(response: response)
        assert_equal('An error occurred while processing your payment.', transaction.message)
      end
    end
  end
end
