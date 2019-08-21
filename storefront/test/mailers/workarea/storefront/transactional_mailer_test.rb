require 'test_helper'

module Workarea
  module Storefront
    class TransactionalMailerTest < MailerTest
      def test_enabled_transactional_emails
        Workarea.config.send_transactional_emails = true

        order = create_placed_order
        OrderMailer.confirmation(order.id).deliver_now

        assert_emails(1)
      end

      def test_disabling_transactionl_email
        Workarea.config.send_transactional_emails = false

        order = create_placed_order
        OrderMailer.confirmation(order.id).deliver_now

        assert_no_emails
      end
    end
  end
end
