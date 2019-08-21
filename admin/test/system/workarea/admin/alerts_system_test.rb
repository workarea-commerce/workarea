require 'test_helper'

module Workarea
  module Admin
    class AlertsSystemTest < SystemTest
      include Admin::IntegrationTest

      def test_admins_see_a_list_of_alerts
        create_product(images: [], description: nil)
        create_product(variants: [])
        create_product(variants: [{ sku: 'NODETAILS' }])
        create_product(
          variants: [
            { sku: 'ID1', details: { 'Color' => %w(red), 'Size' => %w(Large) } },
            { sku: 'ID2', details: { 'Color' => %w(blue) } }
          ]
        )
        create_category(product_ids: [], product_rules: [])
        create_release(name: 'Foo', publish_at: 1.hour.from_now)

        visit admin.root_path
        assert(page.has_content?('9 Alerts'))
        find('button', text: '9 Alerts').hover

        within '#alert_menu' do
          assert(page.has_content?('1 empty category'))
          assert(page.has_content?('3 products missing images'))
          assert(page.has_content?('3 products missing descriptions'))
          assert(page.has_content?('1 product missing variants'))
          assert(page.has_content?('3 products missing categories'))
          assert(page.has_content?('4 products with low inventory'))
          assert(page.has_content?('2 products with variants missing details'))
          assert(page.has_content?('1 product with inconsistent variant details'))
          assert_match(/Foo publishes on/, page.text)
        end

        click_link '1 product missing variants'

        assert_selector('.index-table__row', count: 1)
      end
    end
  end
end
