require 'test_helper'

module Workarea
  module Storefront
    class TransactionalMailerTest < Workarea::IntegrationTest
      def test_enabled_transactional_emails
        Workarea.with_config do |config|
          config.send_transactional_emails = true

          order = create_placed_order
          OrderMailer.confirmation(order.id).deliver_now

          assert(ActionMailer::Base.deliveries.last.present?)
        end
      end

      def test_disabling_transactionl_email
        Workarea.with_config do |config|
          config.send_transactional_emails = false

          order = create_placed_order
          OrderMailer.confirmation(order.id).deliver_now

          assert_nil(ActionMailer::Base.deliveries.last)
        end
      end
    end
  end
end
