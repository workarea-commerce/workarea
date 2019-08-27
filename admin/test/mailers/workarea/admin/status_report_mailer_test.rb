require 'test_helper'

module Workarea
  module Admin
    class StatusReportMailerTest < MailerTest
      include TestCase::SearchIndexing
      include TestCase::Mail

      delegate :t, to: :I18n

      def test_report
        # create a Products Missing Images alert
        create_product(images: [], description: nil)

        Workarea.config.email_from = 'noreply@example.com'
        user = create_user(email: 'bcrouse@workarea.com')

        StatusReportMailer.report(user.email).deliver_now

        email = ActionMailer::Base.deliveries.last
        html = email.parts.second.body

        assert_includes(html, Workarea.config.site_name)
        assert_includes(html, t('workarea.admin.status_report_mailer.orders.total_orders'))
        assert_includes(html, t('workarea.admin.status_report_mailer.alerts.title'))
        assert_includes(html, t('workarea.admin.status_report_mailer.unsubscribe'))
        assert_includes(html, Money.default_currency.symbol)
        assert_includes(email.to, user.email)
        assert_includes(email.from, Workarea.config.email_from)
      end

      def test_report_to_many
        users = [
          create_user(email: 'bcrouse@workarea.com'),
          create_user(email: 'tscott@workarea.com')
        ]

        StatusReportMailer.report_to_many(users).map(&:deliver_now)
        assert_equal(2, ActionMailer::Base.deliveries.count)
      end
    end
  end
end
