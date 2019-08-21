require 'test_helper'

module Workarea
  module DataFile
    class ExportTest < Workarea::TestCase
      def test_email_validation
        export = Export.new(model_type: 'Workarea::Catalog::Product')

        assert(export.valid?)

        export.emails = %w(test@workarea.com test2@workarea.com)
        assert(export.valid?)

        export.emails = %w(test@workarea.com not_an_email)
        refute(export.valid?)
        assert(export.errors[:emails].present?)

        export.emails = %w(not@an_email not_an_email)
        refute(export.valid?)
        assert(export.errors[:emails].present?)
      end
    end
  end
end
