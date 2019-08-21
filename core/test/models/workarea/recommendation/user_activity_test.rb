require 'test_helper'

module Workarea
  module Recommendation
    class UserActivityTest < TestCase
      setup :set_config
      setup :set_user_activity
      teardown :teardown_config

      def set_config
        @uamc = Workarea.config.max_user_activities
        Workarea.config.max_user_activities = 3
      end

      def set_user_activity
        @user_activity = UserActivity.new(
          product_ids: [1, 2, 3],
          category_ids: [4, 5, 6],
          searches: ['one', 'two', 'three']
        )
      end

      def teardown_config
        Workarea.config.max_user_activities = @uamc
      end

      def test_adding_product_ids
        UserActivity.save_product('foo', '1')
        user_activity = UserActivity.find('foo')
        assert_equal(%w(1), user_activity.product_ids)
        assert(user_activity.created_at.present?)

        UserActivity.save_product('foo', '2')
        assert_equal(%w(2 1), user_activity.reload.product_ids)

        UserActivity.save_product('foo', '3')
        assert_equal(%w(3 2 1), user_activity.reload.product_ids)

        UserActivity.save_product('foo', '4')
        assert_equal(%w(4 3 2), user_activity.reload.product_ids)

        current_updated_at = user_activity.reload.updated_at
        UserActivity.save_product('foo', '5')
        refute_equal(current_updated_at, user_activity.reload.updated_at)
      end

      def test_adding_category_ids
        UserActivity.save_category('foo', '1')
        user_activity = UserActivity.find('foo')
        assert_equal(%w(1), user_activity.category_ids)
        assert(user_activity.created_at.present?)

        UserActivity.save_category('foo', '2')
        assert_equal(%w(2 1), user_activity.reload.category_ids)

        UserActivity.save_category('foo', '3')
        assert_equal(%w(3 2 1), user_activity.reload.category_ids)

        UserActivity.save_category('foo', '4')
        assert_equal(%w(4 3 2), user_activity.reload.category_ids)

        current_updated_at = user_activity.reload.updated_at
        UserActivity.save_category('foo', '5')
        refute_equal(current_updated_at, user_activity.reload.updated_at)
      end

      def test_adding_searches
        UserActivity.save_search('foo', 'shirts')
        user_activity = UserActivity.find('foo')
        assert_equal(%w(shirts), user_activity.searches)
        assert(user_activity.created_at.present?)

        UserActivity.save_search('foo', 'pants')
        assert_equal(%w(pants shirts), user_activity.reload.searches)

        UserActivity.save_search('foo', 'shoes')
        assert_equal(%w(shoes pants shirts), user_activity.reload.searches)

        UserActivity.save_search('foo', 'underwear')
        assert_equal(%w(underwear shoes pants), user_activity.reload.searches)

        current_updated_at = user_activity.reload.updated_at
        UserActivity.save_search('foo', 'jacket')
        refute_equal(current_updated_at, user_activity.reload.updated_at)
      end

      def test_id_typecasting
        id = BSON::ObjectId.new
        UserActivity.save_search(id, 'shirts')
        user_activity = UserActivity.find(id)
        assert_equal(%w(shirts), user_activity.searches)
        assert(user_activity.created_at.present?)
      end
    end
  end
end
