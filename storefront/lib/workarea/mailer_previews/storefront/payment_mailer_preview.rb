module Workarea
  module Storefront
    class PaymentMailerPreview < ActionMailer::Preview
      def refunded
        PaymentMailer.refunded(Payment::Refund.first.id)
      end
    end
  end
end
