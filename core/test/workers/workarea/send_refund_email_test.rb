require 'test_helper'

module Workarea
  class SendRefundEmailTest < TestCase
    include TestCase::SearchIndexing
    include TestCase::Mail

    setup :order, :payment

    def order
      @order ||= create_order(email: 'test@workarea.com')
    end

    def payment
      @payment ||=
        create_payment(id: order.id).tap do |payment|
          payment.set_address(
            first_name: 'Ben',
            last_name: 'Crouse',
            street: '22 S. 3rd St.',
            city: 'Philadelphia',
            region: 'PA',
            postal_code: '19106',
            country: 'US',
            phone_number: '2159251800'
          )

          payment.set_credit_card(
            number: '1',
            month: 1,
            year: Time.current.year + 1,
            cvv: '999',
            amount: 5.to_m
          )
        end
    end

    def test_perform
      SendRefundEmail.enable
      payment.purchase!

      refund = Payment::Refund.new(
        payment: payment,
        amounts: { payment.credit_card.id => 5.to_m }
      )

      assert(refund.complete!)

      email = ActionMailer::Base.deliveries.last
      assert_includes(email.to, 'test@workarea.com')
      assert_includes(
        email.subject,
        I18n.t('workarea.storefront.email.order_refund.subject', order_id: order.id)
      )
    ensure
      SendRefundEmail.disable
    end

    def test_no_email_sent_when_amount_is_zero
      SendRefundEmail.enable
      payment.purchase!

      refund = Payment::Refund.new(
        payment: payment,
        amounts: { payment.credit_card.id => 0.to_m }
      )

      assert(refund.complete!)
      assert_empty(ActionMailer::Base.deliveries)
    ensure
      SendRefundEmail.disable
    end
  end
end
