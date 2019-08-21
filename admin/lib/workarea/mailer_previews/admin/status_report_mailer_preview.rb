module Workarea
  module Admin
    class StatusReportMailerPreview < ActionMailer::Preview
      def report
        StatusReportMailer.report('test@workarea.com', Date.current)
      end
    end
  end
end
