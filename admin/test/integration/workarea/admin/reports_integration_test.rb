require 'test_helper'

module Workarea
  module Admin
    class ReportsIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_exporting
        Metrics::ProductByDay.inc(key: { product_id: 'foo' }, orders: 1)
        Metrics::ProductByDay.inc(key: { product_id: 'bar' }, orders: 2)

        assert_difference 'ActionMailer::Base.deliveries.size' do
          post admin.export_report_path,
            params: {
              export: {
                report_type: 'sales_by_product',
                report_params: { sort_by: 'orders' },
                emails: %w(bcrouse@workarea.com foo@workarea.com)
              }
            }
        end

        assert_redirected_to(admin.root_path)
        assert(flash[:success]).present?

        assert_equal(1, Workarea::Reports::Export.count)
        export = Workarea::Reports::Export.first
        assert(export.started_at.present?)
        assert(export.file.present?)
        assert(export.completed_at.present?)

        email = ActionMailer::Base.deliveries.last
        assert_includes(email.bcc, 'bcrouse@workarea.com')
        assert_includes(email.bcc, 'foo@workarea.com')
        email.parts.each do |part|
          assert_includes(part.body, admin.download_report_url(export))
        end

        get admin.download_report_url(export)
        assert_equal(response.body, export.file.data)
      end

      def test_exports_with_errors
        post admin.export_report_path, params: { export: {} }
        assert_redirected_to(admin.root_path)
        assert(flash[:error].present?)

        post admin.export_report_path,
          params: { export: { report_type: 'sales_by_product' } }
        refute(response.redirect?)
        assert(flash[:error].present?)
      end
    end
  end
end
