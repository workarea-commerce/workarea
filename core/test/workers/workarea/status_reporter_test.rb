require 'test_helper'

module Workarea
  class StatusReporterTest < IntegrationTest
    def test_sending_to_emails_in_list
      create_user(email: 'foo@workarea.com', admin: true, status_email_recipient: true)
      create_user(email: 'bar@workarea.com', admin: true, status_email_recipient: true)

      # Check that rendering release works
      create_release(publish_at: Time.current + 1.days)
      create_release(publish_at: Time.current + 2.days)

      StatusReporter.new.perform

      assert_equal(2, ActionMailer::Base.deliveries.count)

      delivery_emails = ActionMailer::Base.deliveries.map(&:to).flatten

      assert(delivery_emails.include?('foo@workarea.com'))
      assert(delivery_emails.include?('bar@workarea.com'))
    end
  end
end
