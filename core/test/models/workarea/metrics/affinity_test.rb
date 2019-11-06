require 'test_helper'

module Workarea
  module Metrics
    class AffinityTest < TestCase
      def test_recents_max
        User.save_affinity(
          id: 'bcrouse@workarea.com',
          action: 'viewed',
          product_ids: 'product_a',
          category_ids: 'category_a',
          search_ids: 'search_a'
        )

        User.save_affinity(
          id: 'bcrouse@workarea.com',
          action: 'viewed',
          product_ids: 'product_b',
          category_ids: 'category_b',
          search_ids: 'search_b'
        )

        User.save_affinity(
          id: 'bcrouse@workarea.com',
          action: 'viewed',
          product_ids: 'product_c',
          category_ids: 'category_c',
          search_ids: 'search_c'
        )

        metrics = User.find('bcrouse@workarea.com')
        assert_equal(%w(product_c), metrics.viewed.recent_product_ids(max: 1))
        assert_equal(%w(product_c product_b), metrics.viewed.recent_product_ids(max: 2))
        assert_equal(%w(product_c product_b product_a), metrics.viewed.recent_product_ids(max: 3))

        assert_equal(%w(category_c), metrics.viewed.recent_category_ids(max: 1))
        assert_equal(%w(category_c category_b), metrics.viewed.recent_category_ids(max: 2))
        assert_equal(%w(category_c category_b category_a), metrics.viewed.recent_category_ids(max: 3))

        assert_equal(%w(search_c), metrics.viewed.recent_search_ids(max: 1))
        assert_equal(%w(search_c search_b), metrics.viewed.recent_search_ids(max: 2))
        assert_equal(%w(search_c search_b search_a), metrics.viewed.recent_search_ids(max: 3))
      end

      def test_recents_uniqueness
        User.save_affinity(
          id: 'bcrouse@workarea.com',
          action: 'viewed',
          product_ids: 'product_a',
          category_ids: 'category_a',
          search_ids: 'search_a'
        )

        User.save_affinity(
          id: 'bcrouse@workarea.com',
          action: 'viewed',
          product_ids: 'product_a',
          category_ids: 'category_b',
          search_ids: 'search_b'
        )

        User.save_affinity(
          id: 'bcrouse@workarea.com',
          action: 'viewed',
          product_ids: 'product_b',
          category_ids: 'category_a',
          search_ids: 'search_b'
        )

        metrics = User.find('bcrouse@workarea.com')
        assert_equal(%w(product_a product_a product_b), metrics.viewed.product_ids)
        assert_equal(%w(product_b product_a), metrics.viewed.recent_product_ids(unique: true))
        assert_equal(%w(product_b product_a product_a), metrics.viewed.recent_product_ids(unique: false))

        assert_equal(%w(category_a category_b category_a), metrics.viewed.category_ids)
        assert_equal(%w(category_a category_b), metrics.viewed.recent_category_ids(unique: true))
        assert_equal(%w(category_a category_b category_a), metrics.viewed.recent_category_ids(unique: false))

        assert_equal(%w(search_a search_b search_b), metrics.viewed.search_ids)
        assert_equal(%w(search_b search_a), metrics.viewed.recent_search_ids(unique: true))
        assert_equal(%w(search_b search_b search_a), metrics.viewed.recent_search_ids(unique: false))
      end
    end
  end
end
