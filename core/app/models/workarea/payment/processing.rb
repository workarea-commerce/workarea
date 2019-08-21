module Workarea
  class Payment
    module Processing
      extend ActiveSupport::Concern
      include ApplicationDocument

      included do
        field :amounts, type: Hash, default: {}
        field :result_transaction_ids, type: Array, default: []

        belongs_to :payment, class_name: 'Workarea::Payment', index: true

        validates :amounts, presence: true

        after_find :demongoize_amounts
        before_validation :clean_amounts

        scope :by_order, ->(order_id) { where(payment_id: order_id) }

        define_callbacks :complete
      end

      def transactions
        @transactions ||= amounts_with_tenders.reduce([]) do |memo, tuple|
          tender, amount = *tuple
          amount_left = amount

          find_reference_transactions_for(tender).each do |reference|
            next if amount_left.zero?

            amount_for_this_txn = if reference.amount < amount_left
                                    reference.amount
                                  else
                                    amount_left
                                  end

            amount_left -= amount_for_this_txn

            memo << tender.build_transaction(
              action: transaction_type,
              amount: amount_for_this_txn,
              reference: reference
            )
          end

          memo
        end
      end

      def complete!
        return false unless valid?

        run_callbacks :complete do
          operation = Operation.new(transactions)
          operation.complete!
          operation.errors.each do |message|
            errors.add(:base, message)
          end

          self.result_transaction_ids = transactions.map(&:id)
          operation.success? && save(validate: false)
        end
      end

      def total
        amounts.values.sum
      end

      private

      def demongoize_amounts
        amounts.keys.each do |key|
          amounts[key] = parse_amount(amounts[key])
        end
      end

      def clean_amounts
        self.amounts = amounts.reduce({}) do |memo, (key, val)|
          memo[key.to_s] = parse_amount(val)
          memo
        end
      end

      def amounts_with_tenders
        @amounts_with_tenders ||= amounts.reduce({}) do |memo, (tender_id, amount)|
          tender = payment.tenders.detect { |t| t.id.to_s == tender_id.to_s }
          memo[tender] = parse_amount(amount) if tender.present?
          memo
        end
      end

      # Deal with inconsistent Mongoid serializing of Money within a Hash field
      def parse_amount(amount)
        if Money === amount || String === amount || Integer === amount || Float === amount
          amount.to_m
        else
          Money.demongoize(amount)
        end
      end
    end
  end
end
