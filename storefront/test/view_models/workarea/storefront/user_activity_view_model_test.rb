require 'test_helper'

module Workarea
  module Storefront
    class UserActivityViewModelTest < TestCase

      setup :set_display_count
      teardown :reset_display_count

      def set_display_count
        @tmp = Workarea.config.user_activity_display_size
        Workarea.config.user_activity_display_size = 2
      end

      def reset_display_count
        Workarea.config.user_activity_display_size = @tmp
      end

      def test_products
        product_one = create_product
        product_two = create_product
        product_three = create_product

        product_ids = [product_one.id, product_one.id, product_two.id, product_three.id]
        user_activity = Recommendation::UserActivity.new(product_ids: product_ids)
        view_model = UserActivityViewModel.new(user_activity)

        assert_equal(2, view_model.products.length)
        assert_equal(product_one, view_model.products.first.model)
        assert_equal(product_two, view_model.products.second.model)

        product_two.update_attributes!(active: false)

        product_ids = [product_one.id, product_two.id]
        user_activity = Recommendation::UserActivity.new(product_ids: product_ids)
        view_model = UserActivityViewModel.new(user_activity)

        assert_equal(1, view_model.products.length)
        assert_equal(product_one, view_model.products.first.model)
      end

      def test_categories
        one = create_category
        two = create_category
        three = create_category
        user_activity =
          Recommendation::UserActivity.new(category_ids: [one.id, one.id, two.id, three.id])

        view_model = UserActivityViewModel.new(user_activity)

        assert_equal(2, view_model.categories.length)
        assert_equal(one.id, view_model.categories.first.id)
        assert_equal(two.id, view_model.categories.second.id)
      end

      def test_searches
        searches = %w(one one two three)
        user_activity = Recommendation::UserActivity.new(searches: searches)
        view_model = UserActivityViewModel.new(user_activity)

        assert_equal(%w(one two), view_model.searches)
      end
    end
  end
end
