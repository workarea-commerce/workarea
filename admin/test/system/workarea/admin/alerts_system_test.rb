require 'test_helper'

module Workarea
  module Admin
    class AlertsSystemTest < SystemTest
      include Admin::IntegrationTest

      def test_admins_see_a_list_of_alerts
        segment = create_segment

        create_product(images: [], description: nil)
        create_product(variants: [], active_segment_ids: [segment.id])
        create_product(variants: [{ sku: 'NODETAILS' }])
        create_product(
          variants: [
            { sku: 'ID1', details: { 'Color' => %w(red), 'Size' => %w(Large) } },
            { sku: 'ID2', details: { 'Color' => %w(blue) } }
          ]
        )
        create_category(product_ids: [], product_rules: [])
        create_release(name: 'Foo', publish_at: 1.hour.from_now)
        create_inventory(id: 'NODETAILS', policy: :standard, available: 1)

        segment.destroy!
        visit admin.root_path
        assert(page.has_content?('10 Alerts'))
        find('button', text: '10 Alerts').hover

        within '#alert_menu' do
          assert(page.has_content?('1 empty category'))
          assert(page.has_content?('3 products missing images'))
          assert(page.has_content?('3 products missing descriptions'))
          assert(page.has_content?('1 product missing variants'))
          assert(page.has_content?('3 products missing categories'))
          assert(page.has_content?('1 product with low inventory'))
          assert(page.has_content?('2 products with variants missing details'))
          assert(page.has_content?('1 product with inconsistent variant details'))
          assert(page.has_content?(t('workarea.admin.layout.alert.missing_segments', count: 1)))
          assert_match(/Foo publishes on/, page.text)
        end

        click_link '1 product missing variants'

        assert_selector('.index-table__row', count: 1)
      end
    end
  end
end
