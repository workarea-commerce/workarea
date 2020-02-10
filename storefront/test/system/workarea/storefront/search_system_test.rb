require 'test_helper'

module Workarea
  module Storefront
    class SearchSystemTest < Workarea::SystemTest
      include Storefront::SystemTest
      include BreakpointHelpers
      setup :set_products
      setup :set_categories
      setup :set_primary_nav
      setup :index_products
      setup :set_search_settings

      def set_products
        @products = [
          create_product(
            name: 'Test Product 1',
            details: { 'Material' => 'Cotton' },
            filters: { 'Size' => ['Large', 'Medium'], 'Color' => 'Red', 'Test' => 'true' },
            created_at: Time.current - 1.hour,
            variants: [{ sku: 'SKU1', regular: 10.to_m }]
          ),
          create_product(
            name: 'Test Product 2',
            details: { 'Material' => 'Wool' },
            filters: { 'Size' => ['Medium', 'Small'], 'Color' => 'Red' },
            variants: [
              { sku: 'SKU2', regular: 5.to_m },
              { sku: 'SKU3', regular: 7.to_m }
            ]
          )
        ]
      end

      def set_categories
        @categories = [
          create_category(name: 'Foo Category', product_ids: [@products.first.id]),
          create_category(name: 'Bar Category', product_ids: [@products.second.id])
        ]
      end

      def set_primary_nav
        primary_1 = create_taxon(name: 'First')
        create_taxon(name: 'Foo Bar', parent: primary_1, navigable: @categories.first)
        primary_2 = create_taxon(name: 'Second')
        create_taxon(parent: primary_2, navigable: @categories.second)
      end

      def index_products
        @products.each { |p| IndexProduct.perform(p) }
      end

      def set_search_settings
        update_search_settings
      end

      def test_standard_results
        %w(test testing tests tested).each do |term|
          visit storefront.search_path(q: term)

          assert(page.has_content?('Test Product 1'))
          assert(page.has_content?('Test Product 2'))

          assert(page.has_content?('10.00'))
          assert(page.has_content?('5.00'))
          assert(page.has_content?('7.00'))

          assert(page.has_content?('Medium (2)'))
          assert(page.has_content?('Small (1)'))
          assert(page.has_no_content?('Red'))
        end
      end

      def test_sorting_results
        visit storefront.search_path(q: 'test')
        select(t('workarea.sorts.price_asc'), from: 'sort_top')
        assert(page.has_ordered_text?('Test Product 2', 'Test Product 1'))

        visit storefront.search_path(q: 'test')
        select(t('workarea.sorts.price_desc'), from: 'sort_top')
        assert(page.has_ordered_text?('Test Product 1', 'Test Product 2'))

        select(t('workarea.sorts.newest'), from: 'sort_top')
        assert(page.has_ordered_text?('Test Product 2', 'Test Product 1'))

        Metrics::ProductByWeek.create!(product_id: @products.second.id, orders: 1_000)
        index_products

        visit storefront.search_path(q: 'test')
        select(t('workarea.sorts.top_sellers'), from: 'sort_top')
        assert(page.has_ordered_text?('Test Product 2', 'Test Product 1'))
      end

      def test_prefers_and_for_multiple_terms
        visit storefront.search_path(q: 'test 1')
        assert(page.has_ordered_text?('Test Product 1', 'Test Product 2'))
      end

      def test_searching_for_product_id
        visit storefront.search_path(q: @products.first.id)
        assert_current_path(storefront.product_path(@products.first))
      end

      def test_searching_for_product_content
        @products.first.update_attributes!(description: 'nice product')
        visit storefront.search_path(q: 'nice')
        assert(page.has_content?(@products.first.name))
      end

      def test_searching_for_product_details
        # SKUs
        visit storefront.search_path(q: 'SKU1')
        assert_current_path(storefront.product_path(@products.first))

        # Category names
        visit storefront.search_path(q: 'Bar')
        assert(page.has_content?(@products.second.name))

        # Details
        visit storefront.search_path(q: 'cotton')
        assert(page.has_content?(@products.first.name))

        # Filters
        visit storefront.search_path(q: 'large')
        assert(page.has_content?(@products.first.name))
      end

      def test_searching_for_out_of_stock_products
        create_inventory(id: 'SKU1', policy: 'standard', available: 0)
        visit storefront.search_path(q: 'test')

        assert(page.has_no_content?('Test Product 1'))
      end

      def test_products_with_display_rules
        @products[0].update_attributes(active: false)
        visit storefront.search_path(q: 'test')

        assert(page.has_no_content?('Test Product 1'))
      end

      def test_filtering_results
        visit storefront.search_path(q: 'test')

        Capybara.match = :first
        click_link 'First (1)'

        # Primary nav filtering
        assert(page.has_content?('Test Product 1'))
        assert(page.has_no_content?('Test Product 2'))
        click_link "First #{t('workarea.storefront.products.remove_filter')}"

        # Price filtering
        click_link "#{currency}10.00 - #{currency}19.99 (1)"
        assert(page.has_content?('Test Product 1'))
        assert(page.has_no_content?('Test Product 2'))
        click_link "#{currency}10.00 - #{currency}19.99 #{t('workarea.storefront.products.remove_filter')}"

        # Config filtering
        click_link 'Small (1)'
        assert(page.has_content?('Test Product 2'))
        assert(page.has_no_content?('Test Product 1'))
        click_link "Small #{t('workarea.storefront.products.remove_filter')}"

        assert(page.has_content?('Test Product 1'))
        assert(page.has_content?('Test Product 2'))

        # Mobile Filters Nav
        resize_window_to('small')
        visit storefront.search_path(q: 'test')

        find('[data-mobile-filter-button]').click
        assert(page.has_selector?('.mobile-filters-nav', visible: true))

        within '.mobile-filters-nav' do
          assert(page.has_content?(/.10.00 - .19.99 \(1\)/))
        end

        page.execute_script("$('body').trigger('click');");
        assert(page.has_selector?('.mobile-filters-nav', visible: false))

        find('[data-mobile-filter-button]').click
        assert(page.has_selector?('.mobile-filters-nav', visible: true))

        within '.mobile-filters-nav' do
          click_button t('workarea.storefront.products.filter_nav_close_button')
        end

        assert(page.has_selector?('.mobile-filters-nav', visible: false))
      end

      def test_filter_and_sorting_results
        visit storefront.search_path(q: 'test')

        Capybara.match = :first
        click_link 'First (1)'
        assert(page.has_content?('Test Product 1'))
        assert(page.has_no_content?('Test Product 2'))

        select(t('workarea.sorts.price_asc'), from: 'sort_top')

        assert(page.has_content?('Test Product 1'))
        assert(page.has_no_content?('Test Product 2'))
      end

      def test_searching_on_a_synonym
        # HACK this is in here because we have an alpha version running in CI
        # where this test breaks and this is the only current theory as to the
        # cause.
        skip if Workarea.elasticsearch.info['version']['number'] =~ /alpha/

        Search::Settings.current.update_attributes!(synonyms: 'test, ben')
        visit storefront.search_path(q: 'ben')

        assert(page.has_content?('Test Product 1'))
        assert(page.has_content?('Test Product 2'))
      end

      def test_searching_on_a_misspelling
        create_product(name: 'Test Product 3')
        visit storefront.search_path(q: 'produt')

        assert(page.has_content?('Info'))
        assert(page.has_content?('Test Product 1'))
        assert(page.has_content?('Test Product 2'))
      end

      def test_search_custom_content
        customization = create_search_customization(id: 'test')
        content = Content.for(customization)
        content.blocks.build(
          area: :above_results,
          type_id: :html,
          data: { html: '<p>Test Product Custom Content</p>' }
        )
        content.save!

        visit storefront.search_path(q: 'test')
        assert(page.has_content?('Test Product Custom Content'))
      end

      def test_search_content
        create_content(
          name: 'search',
          blocks: [
            {
              area: :results,
              type_id: 'html',
              data: { html: 'global search test content' }
            },
            {
              area: :no_results,
              type_id: 'html',
              data: { html: 'no results test content' }
            }
          ]
        )

        visit storefront.search_path(q: 'test')
        assert(page.has_content?('global search test content'))

        visit storefront.search_path(q: 'tp1')
        assert(page.has_content?(t('workarea.storefront.searches.no_results', terms: 'tp1')))
        assert(page.has_content?('no results test content'))
      end
    end
  end
end
