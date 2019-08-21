require 'test_helper'

module Workarea
  module Storefront
    class HeadTagsIntegrationTest < Workarea::IntegrationTest
      setup :set_config
      teardown :reset_config

      def set_config
        @current = Workarea.config.per_page
        Workarea.config.per_page = 1
      end

      def reset_config
        Workarea.config.per_page = @current
      end

      def test_category_tags
        filters = { color: ['Red'] }
        products = Array.new(3) { create_product(filters: filters) }
        category = create_category(
          product_ids: products.map(&:id),
          terms_facets: %w(color)
        )
        page = create_page

        get storefront.page_path(page)
        assert_select('link[rel=canonical]') do |elements|
          assert_equal(1, elements.length)
          assert_equal(storefront.page_url(page), elements.first['href'])
        end

        get storefront.root_path
        assert_select('link[rel=canonical]') do |elements|
          assert_equal(1, elements.length)
          assert_equal(storefront.root_url, elements.first['href'])
        end

        get storefront.category_path(category)
        assert_select('link[rel=canonical]') do |elements|
          assert_equal(1, elements.length)
          assert_equal(storefront.category_url(category), elements[0]['href'])
        end
        assert_select('link[rel=next]') do |elements|
          assert_equal(1, elements.length)
          assert_equal(storefront.category_url(category, page: 2), elements[0]['href'])
        end
        assert_select('link[rel=prev]', false)
        assert_select('meta[name=robots]') do |elements|
          assert_equal(2, elements.length)
          assert_equal('noodp', elements[0]['content'])
          assert_equal('index, follow', elements[1]['content'])
        end

        get storefront.category_path(category, page: 2)
        assert_select('link[rel=canonical]') do |elements|
          assert_equal(1, elements.length)
          assert_equal(storefront.category_url(category, page: 2), elements[0]['href'])
        end
        assert_select('link[rel=next]') do |elements|
          assert_equal(1, elements.length)
          assert_equal(storefront.category_url(category, page: 3), elements[0]['href'])
        end
        assert_select('link[rel=prev]') do |elements|
          assert_equal(1, elements.length)
          assert_equal(storefront.category_url(category), elements[0]['href'])
        end
        assert_select('meta[name=robots]') do |elements|
          assert_equal(2, elements.length)
          assert_equal('noodp', elements[0]['content'])
          assert_equal('noindex, follow', elements[1]['content'])
        end

        get storefront.category_path(category, page: 3)
        assert_select('link[rel=canonical]') do |elements|
          assert_equal(1, elements.length)
          assert_equal(storefront.category_url(category, page: 3), elements[0]['href'])
        end
        assert_select('link[rel=next]', false)
        assert_select('link[rel=prev]') do |elements|
          assert_equal(1, elements.length)
          assert_equal(storefront.category_url(category, page: 2), elements[0]['href'])
        end
        assert_select('meta[name=robots]') do |elements|
          assert_equal(2, elements.length)
          assert_equal('noodp', elements[0]['content'])
          assert_equal('noindex, follow', elements[1]['content'])
        end

        get storefront.category_path(category, filters)
        assert_select('link[rel=canonical]') do |elements|
          assert_equal(1, elements.length)
          assert_equal(storefront.category_url(category), elements[0]['href'])
        end
        assert_select('link[rel=next]') do |elements|
          assert_equal(1, elements.length)
          assert_equal(storefront.category_url(category, page: 2), elements[0]['href'])
        end
        assert_select('link[rel=prev]', false)
        assert_select('meta[name=robots]') do |elements|
          assert_equal(2, elements.length)
          assert_equal('noodp', elements[0]['content'])
          assert_equal('noindex, follow', elements[1]['content'])
        end

        get storefront.category_path(category, filters.merge(page: 2))
        assert_select('link[rel=canonical]') do |elements|
          assert_equal(1, elements.length)
          assert_equal(storefront.category_url(category, page: 2), elements[0]['href'])
        end
        assert_select('link[rel=next]') do |elements|
          assert_equal(1, elements.length)
          assert_equal(storefront.category_url(category, page: 3), elements[0]['href'])
        end
        assert_select('link[rel=prev]') do |elements|
          assert_equal(1, elements.length)
          assert_equal(storefront.category_url(category), elements[0]['href'])
        end
        assert_select('meta[name=robots]') do |elements|
          assert_equal(2, elements.length)
          assert_equal('noodp', elements[0]['content'])
          assert_equal('noindex, follow', elements[1]['content'])
        end
      end
    end
  end
end
