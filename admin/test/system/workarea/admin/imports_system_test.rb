require 'test_helper'

module Workarea
  module Admin
    class ImportsSystemTest < SystemTest
      include Admin::IntegrationTest

      def test_importing_products
        2.times { create_product } # samples

        visit admin.catalog_products_path
        click_link t('workarea.admin.shared.bulk_actions.import')

        assert_current_path(
          admin.new_data_file_import_path(
            return_to: admin.catalog_products_path,
            model_type: Workarea::Catalog::Product
          )
        )

        Workarea.config.data_file_formats[1..-1].each do |format|
          click_link format.upcase
          assert(page.has_content?(format.upcase))
        end
      end

      def test_importing_taxes
        category = create_tax_category

        visit admin.tax_category_path(category)

        click_link t('workarea.admin.tax_categories.cards.rates.title')
        click_link 'bulk_import'
        attach_file 'import[file]', tax_rates_csv_path
        click_button 'create_import'

        assert_current_path(admin.tax_category_path(category))
        assert(page.has_content?('Success'))
      end
    end
  end
end
