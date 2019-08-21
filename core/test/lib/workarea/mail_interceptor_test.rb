require 'test_helper'

module Workarea
  class MailInterceptorTest < TestCase
    setup :persist_config
    setup :temporary_config
    teardown :restore_config

    def test_delivering_email_with_lambda_config
      create_user(email: 'admin@workarea.com', super_admin: true)

      message = create_message(%w(test@workarea.com))
      MailInterceptor.delivering_email(message)
      refute(message.perform_deliveries)

      message = create_message(%w(admin@workarea.com))
      MailInterceptor.delivering_email(message)
      assert(message.perform_deliveries)
    end

    def test_delivering_email_with_boolean_config
      Workarea.config.send_email = false
      message = create_message(%w(test@workarea.com))
      MailInterceptor.delivering_email(message)
      refute(message.perform_deliveries)

      Workarea.config.send_email = true
      message = create_message(%w(test@workarea.com))
      MailInterceptor.delivering_email(message)
      assert(message.perform_deliveries)
    end

    def test_delivering_email_with_no_to_recipients
      admin = create_user(email: 'admin@workarea.com', super_admin: true)
      message = OpenStruct.new(
        to: nil,
        cc: nil,
        bcc: [admin.email],
        perform_deliveries: true
      )
      MailInterceptor.delivering_email(message)
      assert(message.perform_deliveries)
    end

    private

    def persist_config
      @send_email_config = Workarea.config.send_email
    end

    def temporary_config
      Workarea.config.send_email = lambda { |message|
        recipients = (Array(message.to) + Array(message.cc) + Array(message.bcc)).compact
        recipients.any? do |email|
          email.in?(Workarea::User.admins.pluck(:email))
        end
      }
    end

    def restore_config
      Workarea.config.send_email = @send_email_config
    end

    def create_message(emails)
      OpenStruct.new(to: emails, perform_deliveries: true)
    end

  end
end
