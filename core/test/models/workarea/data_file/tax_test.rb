require 'test_helper'

module Workarea
  module DataFile
    class TaxImportTest < TestCase
      def test_process
        tax_category =
          Workarea::Tax::Category.create(code: '001', name: 'Sales')

        import = TaxImport.create!(
          file: File.open(tax_rates_csv_path),
          tax_category_id: tax_category.id.to_s
        )

        import.process!
        tax_category.reload

        assert_equal(2, tax_category.rates.length)

        rate = tax_category.rates.find_by(postal_code: '19021')
        assert_equal('PA', rate.region)
        assert_equal(Country['US'], rate.country)
        assert_equal('19021', rate.postal_code)
        assert_equal(0.06, rate.percentage)
        assert_equal(0.06, rate.region_percentage)
        assert_equal(true, rate.charge_on_shipping)

        rate = tax_category.rates.find_by(postal_code: '19106')
        assert_equal('PA', rate.region)
        assert_equal(Country['US'], rate.country)
        assert_equal('19106', rate.postal_code)
        assert_equal(0.08, rate.percentage)
        assert_equal(0.06, rate.region_percentage)
        assert_equal(0.02, rate.postal_code_percentage)
        assert_equal(0.to_m, rate.tier_min)
        assert_equal(10_000.to_m, rate.tier_max)
        assert_equal(false, rate.charge_on_shipping)
      end

      def test_errors_in_process
        tax_category = create_tax_category

        csv = IO.read(tax_rates_csv_path)
        csv << "PA,1\n,9022,,,asdf,,,\",,,,"
        file = create_tempfile(csv, extension: 'json')

        import = TaxImport.create!(
          file: file,
          tax_category_id: tax_category.id
        )

        assert_no_changes -> { tax_category.reload.rates.to_a } do
          assert_raise(CSV::MalformedCSVError) { import.process! }
        end

        import.reload
        assert_equal('CSV::MalformedCSVError', import.error_type)
        assert(import.error_message.present?)
      end
    end
  end
end
