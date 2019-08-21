module Workarea
  module Storefront
    class RefundViewModel < ApplicationViewModel
      def tenders
        @tenders ||= Hash[
          model.amounts.map do |tender_id, amount|
            tender = payment.tenders.detect { |t| t.id.to_s == tender_id.to_s }
            amount = Money.demongoize(amount)

            [tender, amount]
          end
        ]
      end
    end
  end
end
