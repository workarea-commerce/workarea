require 'test_helper'

module Workarea
  module Admin
    class TransactionViewModelTest < TestCase
      setup :set_tender
      setup :set_transaction

      def set_tender
        @tender = Workarea::Payment::Tender::CreditCard.new
      end

      def set_transaction
        @transaction = TransactionViewModel.new(
          @tender.build_transaction(action: 'authorize', amount: 4.to_m)
        )
      end

      def test_payment_type
        assert_equal('credit_card', @transaction.payment_type)

        @transaction.tender = nil
        assert_equal('missing', @transaction.payment_type)
      end

      def test_payment_title
        assert_equal('Credit Card', @transaction.payment_title)

        @transaction.tender = nil
        assert_equal('Missing Tender', @transaction.payment_title)
      end
    end
  end
end
