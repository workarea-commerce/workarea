require 'test_helper'

module Workarea
  module Admin
    class SearchSystemTest < SystemTest
      include Admin::IntegrationTest

      setup do
        product = create_product(name: 'Foo Product 1')
        create_product(name: 'Foo Product 2')
        create_product(name: 'Foo Product 3', active: false)
        create_category(name: 'Foo Standard Category of Products')
        create_content(name: 'Foo Page', contentable: nil)
        release = create_release(name: 'Foo Release')
        create_menu(name: 'Foo Menu')

        Release.with_current(release.id) do
          product.update_attributes!(name: 'Updated Foo Product 1')
        end
      end

      def test_searching_admin_for_all_types
        visit admin.root_path
        fill_in 'q', with: 'foo'
        click_button 'search_admin'

        assert_equal(admin.search_path, current_path)

        assert(page.has_content?('Foo Product 1'))
        assert(page.has_content?('Foo Product 2'))
        assert(page.has_content?('Foo Product 3'))
        assert(page.has_content?('Foo Standard Category of Products'))
        assert(page.has_content?('Foo Release'))
        assert(page.has_content?('Foo Page'))
        assert(page.has_content?('Foo Menu'))

        click_button 'Show Filters'
        click_button 'Type'
        click_link('Product (3)')

        assert_equal(admin.search_path, current_path)

        assert(page.has_content?('Foo Product 1'))
        assert(page.has_content?('Foo Product 2'))
        assert(page.has_content?('Foo Product 3'))
        assert(page.has_no_content?('Foo Standard Category of Products'))
        assert(page.has_no_content?('Foo Release'))
        assert(page.has_no_content?('Foo Page'))
        assert(page.has_no_content?('Foo Menu'))

        visit admin.root_path
        fill_in 'q', with: 'products'
        click_button 'search_admin'

        click_button 'Show Filters'
        click_button 'Type'
        assert(page.has_content?('Product (3)'))
        click_button 'Type'

        click_button 'Upcoming Changes'
        assert(page.has_content?('Foo Release (1)'))

        assert(page.has_content?('Foo Product 1'))
        assert(page.has_content?('Foo Product 2'))
        assert(page.has_content?('Foo Product 3'))
        assert(page.has_content?('Foo Standard Category of Products'))
        assert(page.has_no_content?('Foo Page'))
      end

      def test_sorting
        visit admin.root_path
        fill_in 'q', with: 'foo'
        click_button 'search_admin'

        select('Name', from: 'sort')
        wait_for_xhr

        assert(
          page.has_ordered_text?(
            'Foo Page',
            'Foo Product',
            'Foo Release',
            'Foo Standard Category of Products'
          )
        )
      end

      def test_sorting_with_filters_applied
        visit admin.root_path
        fill_in 'q', with: 'foo'
        click_button 'search_admin'

        click_button 'Show Filters'
        click_button 'Type'
        click_link 'Product (3)'
        assert(page.has_content?('3 results'))

        select('Name', from: 'sort')
        wait_for_xhr
        assert(page.has_content?('3 results'))
        assert(
          page.has_ordered_text?(
            'Foo Product 1',
            'Foo Product 2',
            'Foo Product 3'
          )
        )
      end
    end
  end
end
