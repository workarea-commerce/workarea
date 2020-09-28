require 'test_helper'

module Workarea
  module Storefront
    class PaginationSystemTest < Workarea::SystemTest
      setup :set_config
      setup :set_products
      setup :set_search_settings
      teardown :reset_config

      def set_config
        @per_page = Workarea.config.per_page
        Workarea.config.per_page = 1

        # Due to 5 XHR requests to load pages, these tests are slow on the build
        # server and headless Chrome.
        @default_max_wait_time = Capybara.default_max_wait_time
        Capybara.default_max_wait_time = 30
      end

      def reset_config
        Workarea.config.per_page = @per_page
        Capybara.default_max_wait_time = @default_max_wait_time
      end

      def set_products
        @products =
          [
            create_product(id: 'PROD1', name: 'Product 1'),
            create_product(id: 'PROD2', name: 'Product 2'),
            create_product(id: 'PROD3', name: 'Product 3'),
            create_product(id: 'PROD4', name: 'Product 4'),
            create_product(id: 'PROD5', name: 'Product 5'),
            create_product(id: 'PROD6', name: 'Product 6')
          ]
      end

      def set_search_settings
        update_search_settings
      end

      def categorize_products(category)
        category.update_attributes!(
          product_ids: @products.map(&:id)
        )
      end

      def test_category_pagination
        category = create_category
        categorize_products(category)

        visit storefront.category_path(category)

        assert(page.has_content?('Product 1'))
        assert(page.has_content?('Product 2'))
        assert(page.has_content?('Product 3'))
        assert(page.has_content?('Product 4'))
        assert(page.has_content?('Product 5'))

        scroll_to_bottom

        refute_text(t('workarea.storefront.pagination.next_page'))
        click_link t('workarea.storefront.pagination.load_more')

        assert_current_path(storefront.category_path(category))
        assert(page.has_content?('Product 1'))
        assert(page.has_content?('Product 2'))
        assert(page.has_content?('Product 3'))
        assert(page.has_content?('Product 4'))
        assert(page.has_content?('Product 5'))
        assert(page.has_content?('Product 6'))

        refute_text(t('workarea.storefront.pagination.load_more'))

        find('a', text: 'Product 6').click
        page.execute_script("history.back()")

        assert_current_path(storefront.category_path(category))

        wait_for_xhr

        refute_text(t('workarea.storefront.pagination.load_more'))

        assert_match(/PROD1.*PROD2.*PROD3.*PROD4.*PROD5.*PROD6/m, page.html)
      end

      def test_search_pagination
        visit storefront.search_path(q: 'Product')

        assert(page.has_content?('Product 1'))
        assert(page.has_content?('Product 2'))
        assert(page.has_content?('Product 3'))
        assert(page.has_content?('Product 4'))
        assert(page.has_content?('Product 5'))

        scroll_to_bottom

        refute_text(t('workarea.storefront.pagination.next_page'))
        click_link t('workarea.storefront.pagination.load_more')

        assert_current_path(storefront.search_path(q: 'Product'))
        assert(page.has_content?('Product 1'))
        assert(page.has_content?('Product 2'))
        assert(page.has_content?('Product 3'))
        assert(page.has_content?('Product 4'))
        assert(page.has_content?('Product 5'))
        assert(page.has_content?('Product 6'))

        refute_text(t('workarea.storefront.pagination.load_more'))

        find('a', text: 'Product 6').click
        page.execute_script("history.back()")

        assert_current_path(storefront.search_path(q: 'Product'))

        wait_for_xhr

        refute_text(t('workarea.storefront.pagination.load_more'))

        assert(page.has_content?('Product 1'))
        assert(page.has_content?('Product 2'))
        assert(page.has_content?('Product 3'))
        assert(page.has_content?('Product 4'))
        assert(page.has_content?('Product 5'))
        assert(page.has_content?('Product 6'))
      end
    end
  end
end
