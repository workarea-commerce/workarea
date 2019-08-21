require 'test_helper'

module Workarea
  class ApplicationMailerTest < IntegrationTest
    def test_from_address_changes
      order = create_placed_order

      Workarea.with_config do |config|
        original_email = 'noregerts@example.com'
        config.email_from = original_email
        control_mail = Storefront::OrderMailer.confirmation(order.id).deliver_now

        assert_equal([original_email], control_mail.from)
      end

      Workarea.with_config do |config|
        changed_email = 'changed@example.com'
        config.email_from = changed_email
        changed_mail = Storefront::OrderMailer.confirmation(order.id).deliver_now

        assert_equal([changed_email], changed_mail.from)
      end
    end
  end
end
