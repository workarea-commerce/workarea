module Workarea
  module Admin
    class PaymentViewModel < ApplicationViewModel
      def transactions
        @transactions ||= TransactionViewModel.wrap(
          tenders.map(&:transactions).flatten
        )
      end

      def can_refund?
        return @can_refund if defined?(@can_refund)
        @can_refund = tenders.any?(&:refundable?)
      end

      def can_capture?
        return @can_capture if defined?(@can_capture)
        @can_capture = tenders.any?(&:capturable?)
      end
    end
  end
end
