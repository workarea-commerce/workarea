require 'test_helper'

module Workarea
  module Reports
    class ExportTest < TestCase
      def test_email_validation
        export = Export.new(emails_list: 'bcrouse@weblinc.com, foo')
        refute(export.valid?)
        assert(export.errors[:emails].present?)
      end

      def test_process
        export = Export.new(
          report_type: 'sales_by_product',
          report_params: { sort_by: 'orders' },
          emails: %w(bcrouse@workarea.com)
        )

        export.process! { |csv| csv << %w(foo bar baz) }

        assert(export.started_at.present?)
        assert(export.file.present?)
        assert(export.completed_at.present?)

        results = CSV.parse(export.file.data)
        assert_equal(1, results.size)
        assert_equal('foo', results.first.first)
        assert_equal('bar', results.first.second)
        assert_equal('baz', results.first.third)
      end
    end
  end
end
