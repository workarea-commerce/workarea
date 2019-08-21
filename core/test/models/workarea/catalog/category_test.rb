require 'test_helper'

module Workarea
  module Catalog
    class CategoryTest < TestCase
      include FeaturedProductsTest
      include NavigableTest

      def featured_product_model
        @featured_product_model ||= create_category
      end

      def navigable_class
        Category
      end

      def test_valid?
        category = Category.new(product_ids: ['', nil, '1234'])
        category.valid?

        assert_equal(['1234'], category.product_ids)
      end

      def test_unique_client_ids
        category_1 = create_category
        category_2 = create_category
        category_3 = create_category(client_id: nil)
        category_4 = create_category(client_id: nil)
        category_5 = create_category(client_id: 'test')
        category_6 = Category.new(client_id: 'test')

        assert_nil(category_1.client_id)
        assert_nil(category_2.client_id)
        assert_nil(category_3.client_id)
        assert_nil(category_4.client_id)
        assert_equal('test', category_5.client_id)
        refute(category_6.valid?)
      end
    end
  end
end
