require 'test_helper'

module Workarea
  module Admin
    class JumpToIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_requiring_admin_log
        set_current_user(nil)
        get admin.jump_to_path(q: 'test')
        assert(response.redirect?)

        set_current_user(create_user)
        get admin.jump_to_path(q: 'test')
        assert(response.redirect?)
      end

      def test_finding_admin_navigation
        Workarea.config.jump_to_navigation.to_a.each do |tuple|
          Workarea::Search::Admin::Navigation.new(tuple).save

          get admin.jump_to_path(q: tuple.first)

          results = JSON.parse(response.body)['results']
          assert_equal(tuple.first, results.first['label'])
          assert_equal('Admin Pages', results.first['type'])
        end
      end

      def test_finding_variants
        product = create_product(
          name: 'Test Product',
          variants: [{ sku: 'SKU', regular: 5.00, name: 'Test Variant' }]
        )
        get admin.jump_to_path(q: 'test v')

        results = JSON.parse(response.body)['results']
        assert_equal(1, results.length)

        assert_equal("Test Product (#{product.id})", results.first['label'])
        assert_equal('Products', results.first['type'])
        assert_equal(admin.catalog_product_path(product), results.first['url'])

        product.destroy

        get admin.jump_to_path(q: 'test v')
        results = JSON.parse(response.body)['results']
        assert_equal(0, results.length)
      end

      def test_finding_products
        product = create_product(name: 'Test Product')
        get admin.jump_to_path(q: 'test p')

        results = JSON.parse(response.body)['results']
        assert_equal(1, results.length)

        assert_equal("Test Product (#{product.id})", results.first['label'])
        assert_equal('Products', results.first['type'])
        assert_equal(admin.catalog_product_path(product), results.first['url'])

        product.destroy

        get admin.jump_to_path(q: 'test p')
        results = JSON.parse(response.body)['results']
        assert_equal(0, results.length)
      end

      def test_finding_categories
        category = create_category(name: 'Test Category')
        get admin.jump_to_path(q: 'te')

        results = JSON.parse(response.body)['results']
        assert_equal(1, results.length)

        assert_equal('Test Category', results.first['label'])
        assert_equal('Categories', results.first['type'])
        assert_equal(admin.catalog_category_path(category), results.first['url'])

        category.destroy

        get admin.jump_to_path(q: 'te')
        results = JSON.parse(response.body)['results']
        assert_equal(0, results.length)
      end

      def test_finding_prices
        sku = create_pricing_sku(id: 'SKU123', prices: [{ regular: 4 }])
        get admin.jump_to_path(q: 'sk')

        results = JSON.parse(response.body)['results']
        assert_equal(1, results.length)
        assert_equal(
          "SKU123 - #{Money.default_currency.symbol}4.00",
          results.first['label']
        )
        assert_equal('Pricing Skus', results.first['type'])
        assert_equal(admin.pricing_sku_path(sku), results.first['url'])

        sku.destroy

        get admin.jump_to_path(q: 'sk')
        results = JSON.parse(response.body)['results']
        assert_equal(0, results.length)
      end

      def test_finding_inventory
        inventory = create_inventory(id: 'SKU123', available: 4)
        get admin.jump_to_path(q: 'sk')

        results = JSON.parse(response.body)['results']
        assert_equal(1, results.length)
        assert_equal(
          t('workarea.inventory_sku.jump_to_text', id: 'SKU123', count: 4),
          results.first['label']
        )
        assert_equal('Inventory Skus', results.first['type'])
        assert_equal(admin.inventory_sku_path(inventory), results.first['url'])

        inventory.destroy

        get admin.jump_to_path(q: 'sk')
        results = JSON.parse(response.body)['results']
        assert_equal(0, results.length)
      end

      def test_finding_content_assets
        asset = create_asset(name: 'Test Asset')
        get admin.jump_to_path(q: 'te')

        results = JSON.parse(response.body)['results']
        assert_equal(1, results.length)
        assert_equal('Test Asset - product_image.jpg', results.first['label'])
        assert_equal('Assets', results.first['type'])
        assert_equal(admin.content_asset_path(asset), results.first['url'])

        asset.destroy

        get admin.jump_to_path(q: 'te')
        results = JSON.parse(response.body)['results']
        assert_equal(0, results.length)
      end

      def test_finding_releases
        release = create_release(name: 'Test Release')
        get admin.jump_to_path(q: 'te')

        results = JSON.parse(response.body)['results']
        assert_equal(1, results.length)
        assert_equal('Test Release (Not scheduled)', results.first['label'])
        assert_equal('Releases', results.first['type'])
        assert_equal(admin.release_path(release), results.first['url'])

        release.destroy

        get admin.jump_to_path(q: 'te')
        results = JSON.parse(response.body)['results']
        assert_equal(0, results.length)
      end

      def test_finding_discounts
        discount = create_order_total_discount(name: 'Test Discount')
        get admin.jump_to_path(q: 'te')

        results = JSON.parse(response.body)['results']
        assert_equal(1, results.length)
        assert_equal('Test Discount', results.first['label'])
        assert_equal('Discounts', results.first['type'])
        assert_equal(admin.pricing_discount_path(discount), results.first['url'])

        discount.destroy

        get admin.jump_to_path(q: 'te')
        results = JSON.parse(response.body)['results']
        assert_equal(0, results.length)
      end

      def test_finding_users
        user = create_user(email: 'jumpto@workarea.com')
        get admin.jump_to_path(q: 'jum')

        results = JSON.parse(response.body)['results']
        assert_equal(1, results.length)
        assert_equal('jumpto@workarea.com - Ben Crouse', results.first['label'])
        assert_equal('Users', results.first['type'])
        assert_equal(admin.user_path(user), results.first['url'])

        user.destroy

        get admin.jump_to_path(q: 'jum')
        results = JSON.parse(response.body)['results']
        assert_equal(0, results.length)
      end

      def test_finding_orders
        order = create_placed_order(id: 'ZXCV1234')
        get admin.jump_to_path(q: 'zxc')

        results = JSON.parse(response.body)['results']
        assert_equal(1, results.length)
        assert_match(/ZXCV1234/, results.first['label'])
        assert_equal('Orders', results.first['type'])
        assert_equal(admin.order_path(order.id), results.first['url'])
      end

      def test_finding_pages
        page = create_page(name: 'Test Page')
        get admin.jump_to_path(q: 'te')

        results = JSON.parse(response.body)['results']
        assert_equal(1, results.length)

        assert_equal('Test Page', results.first['label'])
        assert_equal('Content Pages', results.first['type'])
        assert_equal(admin.content_page_path(page), results.first['url'])

        page.destroy

        get admin.jump_to_path(q: 'te')
        results = JSON.parse(response.body)['results']
        assert_equal(0, results.length)
      end

      def test_finding_system_content
        content = create_content(name: 'Home Page')
        get admin.jump_to_path(q: 'home')

        results = JSON.parse(response.body)['results']
        assert_equal(1, results.length)
        assert_equal('Home Page', results.first['label'])
        assert_equal('System Pages', results.first['type'])
        assert_equal(admin.content_path(content), results.first['url'])

        content.destroy

        get admin.jump_to_path(q: 'home')
        results = JSON.parse(response.body)['results']
        assert_equal(0, results.length)
      end

      def test_limiting_results_by_type
        Workarea.config.jump_to_type_limit = 2
        Workarea.config.jump_to_results_per_type = 2

        5.times { |i| create_product(name: "Test Product #{i}") }
        5.times { |i| create_category(name: "Test Category #{i}") }

        get admin.jump_to_path(q: 'test')
        results = JSON.parse(response.body)['results']

        assert_equal(
          %w(Products Products Categories Categories),
          results.map { |r| r['type'] }
        )
      end

      def test_sorting_by_recency
        create_user(email: 'foo-one@workarea.com', updated_at: 1.day.ago)
        create_user(email: 'foo-two@workarea.com', updated_at: 1.hour.ago)
        get admin.jump_to_path(q: 'foo')

        results = JSON.parse(response.body)['results']
        assert_equal(2, results.length)
        assert_match('foo-two@workarea.com', results.first['label'])
        assert_match('foo-one@workarea.com', results.second['label'])
      end
    end
  end
end
