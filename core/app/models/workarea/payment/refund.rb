module Workarea
  class Payment
    class Refund
      include Processing

      field :includes_shipping, type: Boolean, default: false
      validate :refundable_amounts

      def transaction_type
        'refund'
      end

      def find_reference_transactions_for(tender)
        tender.transactions.successful.not_canceled.captures_or_purchased
      end

      # Set amounts for tenders automatically (as opposed to custom amounts)
      # This will reset the current amount!
      def allocate_amounts!(total:)
        self.amounts = {}
        allocated_amount = 0.to_m

        payment.tenders.reverse.each do |tender|
          amount_for_this_tender = total - allocated_amount

          if amount_for_this_tender > tender.refundable_amount
            amount_for_this_tender = tender.refundable_amount
          end

          allocated_amount += amount_for_this_tender
          amounts[tender.id] = amount_for_this_tender
        end
      end

      def refundable_amounts
        amounts_with_tenders.each do |tender, amount|
          if tender.refundable_amount < amount
            errors.add(tender.slug, I18n.t('workarea.payment.exceeds_captured_amount'))
          end
        end
      end
    end
  end
end
