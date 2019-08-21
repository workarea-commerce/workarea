require 'test_helper'

module Workarea
  module Storefront
    class RefundViewModelTest < TestCase
      def test_tenders
        order = create_placed_order
        payment = Payment.find(order.id)
        amounts = payment.tenders.reduce({}) { |m, t| m.merge(t.id => t.amount) }

        Payment::Capture.new(payment: payment, amounts: amounts).complete!
        refund = Payment::Refund
                  .new(payment: payment, amounts: amounts)
                  .tap(&:complete!)

        view_model = RefundViewModel.wrap(refund)
        assert_equal(1, view_model.tenders.size)
        assert_equal(payment.credit_card, view_model.tenders.keys.first)
        assert_equal(payment.credit_card.amount, view_model.tenders.values.first)
      end
    end
  end
end
