module Workarea
  class Payment
    class Tender
      include ApplicationDocument
      include GuardNegativePrice

      field :amount, type: Money, default: 0

      embedded_in :payment,
        class_name: 'Workarea::Payment'

      has_many :transactions,
        class_name: 'Workarea::Payment::Transaction',
        inverse_of: :tender

      delegate :profile, :address, to: :payment, allow_nil: true
      delegate :email, to: :profile, allow_nil: true

      def build_transaction(attributes)
        txn_attributes = { amount: amount }.merge(attributes)
        Transaction.new(txn_attributes.merge(tender: self, payment: payment))
      end

      def slug
        raise NotImplementedError, "#{self.class} must implement #slug"
      end

      def name
        slug.to_s.humanize
      end

      def has_amount?
        amount > 0.to_m
      end

      def authorized_amount
        transactions.successful.not_canceled.authorizes.sum(&:amount).to_m
      end

      # Include captured or purchased to represent how much money we've taken
      # from the customer on this tender.
      def captured_amount
        transactions
          .successful
          .not_canceled
          .captures_or_purchased
          .sum(&:amount)
          .to_m
      end

      # Exclude purchases - this is the amount of authorized funds that haven't
      # yet been captured.
      def uncaptured_amount
        guard_negative_price do
          authorized_amount - transactions.successful.captures.sum(&:amount).to_m
        end
      end

      def refunded_amount
        transactions.successful.not_canceled.refunds.sum(&:amount).to_m
      end

      def capturable_amount
        guard_negative_price { authorized_amount - captured_amount }
      end

      def refundable_amount
        guard_negative_price { captured_amount - refunded_amount }
      end

      def refundable?
        refundable_amount > 0
      end

      def capturable?
        capturable_amount > 0
      end
    end
  end
end
