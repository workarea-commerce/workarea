require 'test_helper'

module Workarea
  module Admin
    class StatusReportMailerTest < TestCase
      include TestCase::SearchIndexing
      include TestCase::Mail

      delegate :t, to: :I18n

      def test_showing_dashboard_data
        Workarea.with_config do |config|
          config.email_from = 'noreply@example.com'

          addresses = %w(
            bcrouse@workarea.com
            tscott@workarea.com
          )
          from = [Workarea.config.email_from]
          StatusReportMailer
            .report(addresses, Time.zone.parse('2013/11/13'))
            .deliver_now

          email = ActionMailer::Base.deliveries.last
          html = email.parts.second.body

          assert_includes(html, Workarea.config.site_name)
          assert_includes(html, t('workarea.admin.status_report_mailer.orders.total_orders'))
          assert_includes(html, t('workarea.admin.status_report_mailer.alerts.title'))
          assert_includes(html, Money.default_currency.symbol)
          assert_equal(addresses, email.bcc)
          assert_nil(email.to)
          assert_equal(from, email.from)
        end
      end
    end
  end
end
