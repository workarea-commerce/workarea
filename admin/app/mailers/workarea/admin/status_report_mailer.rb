# frozen_string_literal: true
module Workarea
  module Admin
    class StatusReportMailer < Admin::ApplicationMailer
      add_template_helper(InsightsHelper)

      # Build a collection of report mail messages for the given users.
      #
      # NOTE: We intentionally do not share pre-computed alerts/dashboard here.
      # Passing keyword arguments through ActionMailer's class-level
      # method_missing (which stores args for later delivery) does not work
      # reliably in Ruby 3.0+ because kwargs are no longer implicitly splatted
      # from a trailing Hash.  Each call to report/2 will compute its own
      # AlertsViewModel and DashboardsViewModel, which is the safe fallback.
      def self.report_to_many(users)
        users.map { |user| report(user.email) }
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
