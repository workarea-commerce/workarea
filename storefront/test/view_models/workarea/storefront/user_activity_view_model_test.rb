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
        product_three = create_product(
          details:  { 'Material' => 'Wool', 'Style' => '12345' },
          filters:  { 'Material' => 'Wool', 'Style' => '12345' }
        )
        [product_three, product_two, product_one, product_one].each do |product|
          Metrics::User.save_affinity(id: 'foo', action: 'viewed', product_ids: product.id)
        end

        metrics = Metrics::User.find('foo')
        view_model = UserActivityViewModel.new(metrics)

        assert_equal(2, view_model.products.length)
        assert_equal(product_one, view_model.products.first.model)
        assert_equal(product_two, view_model.products.second.model)

        product_two.update_attributes!(active: false)
        view_model = UserActivityViewModel.new(metrics)

        assert_equal(1, view_model.products.length)
        assert_equal(product_one, view_model.products.first.model)

        view_model = UserActivityViewModel.new(metrics, 'Material' => 'Wool')
        assert_equal 'Wool', view_model.products.first.options['Material']
      end

      def test_categories
        one = create_category
        two = create_category
        three = create_category
        [three, two, one, one].each do |category|
          Metrics::User.save_affinity(id: 'foo', action: 'viewed', category_ids: category.id)
        end

        metrics = Metrics::User.find('foo')
        view_model = UserActivityViewModel.new(metrics)

        assert_equal(2, view_model.categories.length)
        assert_equal(one.id, view_model.categories.first.id)
        assert_equal(two.id, view_model.categories.second.id)
      end
    end
  end
end
