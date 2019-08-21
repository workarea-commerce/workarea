require 'test_helper'

module Workarea
  module Admin
    class ImportTaxesIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_can_create_an_import
        category = create_tax_category

        post admin.data_file_tax_imports_path,
          params: {
            import: {
              file: Rack::Test::UploadedFile.new(tax_rates_csv_path),
              tax_category_id: category.id.to_s
            }
          }

        assert_equal(1, DataFile::TaxImport.count)

        import = DataFile::TaxImport.first
        assert(import.file.present?)
        assert(import.created_by_id.present?)

        category.reload
        assert_equal(2, category.rates.count)
      end
    end
  end
end
