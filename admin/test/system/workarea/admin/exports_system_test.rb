require 'test_helper'

module Workarea
  module Admin
    class ExportsSystemTest < SystemTest
      include Admin::IntegrationTest

      def test_exporting_orders
        2.times { |i| create_placed_order(id: "FOO#{i}") }
        visit admin.orders_path
        assert(page.has_content?('FOO0'))
        assert(page.has_content?('FOO1'))

        click_button t('workarea.admin.shared.bulk_actions.export')
        assert(page.has_content?('FOO0'))
        assert(page.has_content?('FOO1'))

        Workarea.config.data_file_formats[1..-1].each do |format|
          click_link format.upcase
          assert(page.has_content?(format.upcase))
          assert(page.has_content?('FOO0'))
          assert(page.has_content?('FOO1'))
        end

        fill_in 'export[emails_list]', with: 'bcrouse@weblinc.com,test@weblinc.com'
        click_button 'create_export'

        assert_current_path(admin.orders_path)
        assert(page.has_content?('Success'))
      end

      def test_exporting_by_selection
        products = Array.new(3) { create_product }
        visit admin.catalog_products_path

        check "catalog_product_#{products.first.id}"
        check "catalog_product_#{products.second.id}"

        assert(page.has_content?('2 selected'))
        click_button t('workarea.admin.shared.bulk_actions.export')

        fill_in 'export[emails_list]', with: 'bcrouse@weblinc.com'
        click_button 'create_export'

        assert_current_path(admin.catalog_products_path)
        assert(page.has_content?('Success'))
        assert_equal(2, DataFile::Export.first.models.count)
      end

      def test_exporting_generated_promo_codes
        code_list = create_code_list

        visit admin.promo_codes_pricing_discount_code_list_path(code_list)
        click_link t('workarea.admin.shared.bulk_actions.export')
        fill_in 'export[emails_list]', with: 'bcrouse@weblinc.com'
        click_button 'create_export'

        assert_current_path(admin.pricing_discount_code_list_path(code_list))
        assert(page.has_content?('Success'))
      end
    end
  end
end
