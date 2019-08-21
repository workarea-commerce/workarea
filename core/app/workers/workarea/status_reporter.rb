module Workarea
  class StatusReporter
    include Sidekiq::Worker

    def perform(*)
      emails = User.status_email_recipients
      yesterday = Time.current - 1.day

      Admin::StatusReportMailer.report(emails, yesterday).deliver_now
    end
  end
end
