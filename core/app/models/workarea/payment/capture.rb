module Workarea
  class Payment
    class Capture
      include Processing

      validate :capture_amounts

      def transaction_type
        'capture'
      end

      def find_reference_transactions_for(tender)
        tender.transactions.successful.not_canceled.authorizes
      end

      # Set amounts for tenders automatically (as opposed to custom amounts)
      # This will reset the current amounts!
      def allocate_amounts!(total:)
        self.amounts = {}
        allocated_amount = 0.to_m

        payment.tenders.each do |tender|
          amount_for_this_tender = total - allocated_amount

          if amount_for_this_tender > tender.capturable_amount
            amount_for_this_tender = tender.capturable_amount
          end

          allocated_amount += amount_for_this_tender
          amounts[tender.id] = amount_for_this_tender
        end
      end

      def capture_amounts
        amounts_with_tenders.each do |tender, amount|
          if tender.capturable_amount < amount
            errors.add(tender.slug, I18n.t('workarea.payment.exceeds_authed_amount'))
          end
        end
      end
    end
  end
end
