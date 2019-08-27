module Workarea
  module Admin
    class StatusReportMailerPreview < ActionMailer::Preview
      def report
        user = User.status_email_recipients.to_a.first
        email = user&.email || 'test@workarea.com'
        StatusReportMailer.report(email, user: user)
      end
    end
  end
end
