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

    def test_finding_categories_based_on_current_release
      release = create_release(publish_at: 1.day.from_now)
      category_one = create_category
      category_two = create_category(product_ids: [@product.id])

      release.as_current do
        category_one.update!(product_ids: [@product.id])
        assert_equal(
          [category_two.id.to_s, category_one.id.to_s],
          Categorization.new(@product).to_a
        )
      end

      release.changesets.destroy_all
      category_one.reload.update!(product_ids: [@product.id])

      release.as_current do
        category_one.update!(product_ids: [])
        assert_equal([category_two.id.to_s], Categorization.new(@product).to_a)
      end

      create_release(publish_at: 2.days.from_now).as_current do
        assert_equal([category_two.id.to_s], Categorization.new(@product).to_a)
      end
    end

    def test_finding_rule_categories_based_on_current_release
      bar = create_product(name: 'Bar')
      category_one = create_category(product_rules: [{ name: 'search', operator: 'equals', value: 'foo' }])
      category_two = create_category(product_rules: [{ name: 'search', operator: 'equals', value: 'bar' }])

      assert_equal([category_one.id.to_s], Categorization.new(@product).queries)
      assert_equal([category_two.id.to_s], Categorization.new(bar).queries)

      release = create_release
      release.as_current do
        category_one.product_rules.first.update!(name: 'search', operator: 'equals', value: 'bar')

        assert_equal([], Categorization.new(@product).queries)
        assert_equal(
          [category_two.id.to_s, category_one.id.to_s],
          Categorization.new(bar).queries
        )
      end

      assert_equal([category_one.id.to_s], Categorization.new(@product).queries)
      assert_equal([category_two.id.to_s], Categorization.new(bar).queries)
    end
  end
end
