module Workarea
  module Admin
    class StatusReportMailer < Admin::ApplicationMailer
      add_template_helper(InsightsHelper)

      def report(emails, date)
        @alerts = AlertsViewModel.wrap(Alerts.new)
        @date = date
        @dashboard = Dashboards::IndexViewModel.new

        mail(
          bcc: emails,
          from: Workarea.config.email_from,
          subject: t('workarea.admin.status_report_mailer.title')
        )
      end
    end
  end
end
