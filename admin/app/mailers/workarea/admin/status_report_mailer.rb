module Workarea
  module Admin
    class StatusReportMailer < Admin::ApplicationMailer
      add_template_helper(InsightsHelper)

      def self.report_to_many(users)
        alerts = AlertsViewModel.wrap(Alerts.new)
        dashboard = Dashboards::IndexViewModel.new

        users.map do |user|
          report(user.email, user: user, alerts: alerts, dashboard: dashboard)
        end
      end

      def report(email, user: nil, alerts: nil, dashboard: nil)
        @date = Time.current - 1.day
        @user = user || User.find_by_email(email)
        @alerts = alerts || AlertsViewModel.wrap(Alerts.new)
        @dashboard = dashboard || Dashboards::IndexViewModel.new

        mail(
          to: email,
          from: Workarea.config.email_from,
          subject: t(
            'workarea.admin.status_report_mailer.subject',
            site: Workarea.config.site_name
          )
        )
      end
    end
  end
end
