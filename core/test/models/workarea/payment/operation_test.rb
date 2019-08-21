require 'test_helper'

module Workarea
  class Payment
    class OperationTest < TestCase
      setup :setup_classes
      teardown :remove_classes

      def setup_classes
        Workarea::Payment.const_set('Test', Module.new)
        Workarea::Payment::Test.const_set(
          'CreditCard',
          Class.new do
            include Payment::OperationImplementation

            cattr_accessor :success, :message
            self.success = true
            self.message = 'Credit card message'

            def complete!
              transaction.response = ActiveMerchant::Billing::Response.new(
                self.class.success,
                self.class.message
              )
            end

            def cancel!
              transaction.cancellation = ActiveMerchant::Billing::Response.new(
                true,
                'Credit card canceled'
              )
            end
          end
        )

        Workarea::Payment::Test.const_set(
          'StoreCredit',
          Class.new do
            include Payment::OperationImplementation

            cattr_accessor :success, :message, :error
            self.success = true
            self.message = 'Store credit message'

            def complete!
              if self.class.error
                raise RuntimeError
              else
                transaction.response = ActiveMerchant::Billing::Response.new(
                  self.class.success,
                  self.class.message
                )
              end
            end

            def cancel!
            end
          end
        )
      end

      def remove_classes
        Workarea::Payment.send(:remove_const, 'Test')
      end

      def profile
        @profile ||= create_payment_profile
      end

      def payment
        @payment ||= create_payment(profile: profile)
      end

      def credit_card
        @credit_card ||= payment.build_credit_card(amount: 5.to_m)
      end

      def store_credit
        @store_credit ||= payment.build_store_credit(amount: 6.to_m)
      end

      def credit_card_transaction
        @credit_card_transaction ||= credit_card.build_transaction(action: 'test')
      end

      def store_credit_transaction
        @store_credit_transaction ||= store_credit.build_transaction(action: 'test')
      end

      def test_complete!
        operation = Operation.new(
          [credit_card_transaction, store_credit_transaction]
        )

        operation.complete!

        operation.transactions.each do |transaction|
          assert(transaction.success)
          assert(transaction.message.present?)
        end

        operation = Operation.new(
          [credit_card_transaction, store_credit_transaction]
        )

        Test::StoreCredit.success = false

        operation.complete!
        assert(operation.transactions.first.canceled_at.present?)

        operation = Operation.new(
          [credit_card_transaction, store_credit_transaction]
        )

        Test::StoreCredit.success = false
        Test::StoreCredit.message = 'Failure message'

        operation.complete!

        refute(operation.success?)
        assert_equal(1, operation.errors.length)
        assert_equal(
          'There was a problem processing your payment. Failure message',
          operation.errors.first
        )

        operation = Operation.new(
          [credit_card_transaction, store_credit_transaction]
        )

        Test::StoreCredit.error = true
        Test::StoreCredit.success = false
        Test::StoreCredit.message = 'Failure message'

        operation.complete! rescue nil

        refute(operation.success?)
        assert_equal(1, operation.errors.length)
        assert(operation.transactions.first.cancellation.present?)
      end
    end
  end
end
