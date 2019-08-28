module Workarea
  class StatusReporter
    include Sidekiq::Worker

    def perform(*)
      users = User.status_email_recipients.to_a
      Admin::StatusReportMailer.report_to_many(users).each(&:deliver_now)
    end
  end
end
