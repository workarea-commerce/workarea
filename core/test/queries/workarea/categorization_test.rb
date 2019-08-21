require 'test_helper'

module Workarea
  class CategorizationTest < IntegrationTest
    setup :set_product

    def set_product
      @product = create_product(name: 'Foo')
    end

    def test_includes_categories_from_manual_placement
      category_one = create_category(product_ids: [@product.id])
      category_two = create_category(product_ids: [@product.id])

      categorization = Categorization.new(@product)
      assert_includes(categorization, category_one.id.to_s)
      assert_includes(categorization, category_two.id.to_s)
    end

    def test_includes_rule_based_categories
      category_one = create_category(
        product_rules: [{ name: 'search', operator: 'equals', value: 'foo' }]
      )

      category_two = create_category(
        product_rules: [{ name: 'search', operator: 'equals', value: 'foo' }]
      )

      categorization = Categorization.new(@product)
      assert_includes(categorization, category_one.id.to_s)
      assert_includes(categorization, category_two.id.to_s)
    end

    def test_default_uses_the_oldest_active_category
      category_one = create_category(
        product_ids: [@product.id],
        created_at: 1.day.ago
      )

      create_category(
        product_ids: [@product.id],
        created_at: 2.hours.ago
      )

      create_category(
        product_ids: [@product.id],
        created_at: 3.hours.ago,
        active: false
      )

      create_category(
        product_ids: [@product.id]
      )

      categorization = Categorization.new(@product)
      assert_equal(category_one.id, categorization.default)
    end

    def test_manual_default
      category_one = create_category(
        product_ids: [@product.id],
        created_at: 2.hours.ago
      )
      category_two = create_category

      @product.update_attributes(default_category_id: category_two.id)

      categorization = Categorization.new(@product)
      assert_equal(category_one.id, categorization.default)

      category_two.update_attributes(product_ids: [@product.id])

      categorization = Categorization.new(@product)
      assert_equal(category_two.id, categorization.default)

      category_two.update_attributes(active: false)

      categorization = Categorization.new(@product)
      assert_equal(category_one.id, categorization.default)
    end

    def test_null_object
      categorization = Categorization.new
      assert_equal(0, categorization.size)
      assert_equal([], categorization.to_models)
    end
  end
end
