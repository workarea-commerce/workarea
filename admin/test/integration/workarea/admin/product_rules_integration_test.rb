require 'test_helper'

module Workarea
  module Admin
    class ProductRulesIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      setup :set_category

      def set_category
        @category = create_category(product_rules: [])
      end

      def test_create
        post admin.product_list_product_rules_path(@category.to_global_id),
          params: {
            return_to: admin.root_path,
            product_rule: {
              name: 'price',
              operator: 'greater_than',
              value: '10'
            }
          }

        assert_redirected_to(admin.root_path)

        @category.reload

        assert_equal(1, @category.product_rules.length)
        assert_equal('price', @category.product_rules.first.name)
        assert_equal('numeric.price', @category.product_rules.first.field)
        assert_equal('greater_than', @category.product_rules.first.operator)
        assert_equal('10', @category.product_rules.first.value)
      end

      def test_update
        rule = @category.product_rules.create!(
          name: 'price',
          operator: 'greater_than',
          value: '10'
        )

        patch admin.product_list_product_rule_path(@category.to_global_id, rule),
          params: {
            return_to: admin.root_path,
            product_rule: {
              name: 'search',
              operator: 'equals',
              value: 'foo'
            }
          }

        assert_redirected_to(admin.root_path)

        @category.reload

        assert_equal(1, @category.product_rules.length)
        assert_equal('search', @category.product_rules.first.name)
        assert_equal('equals', @category.product_rules.first.operator)
        assert_equal('foo', @category.product_rules.first.value)
      end

      def test_destroy
        rule = @category.product_rules.create!(
          name: 'price',
          operator: 'greater_than',
          value: '10'
        )

        delete admin.product_list_product_rule_path(@category.to_global_id, rule),
          params: { return_to: admin.root_path }

        assert_redirected_to(admin.root_path)
        assert(@category.reload.product_rules.empty?)
      end

      def test_validate_query_syntax
        rule = @category.product_rules.create!(
          name: 'search',
          operator: 'equals',
          value: '[created_at-30d TO now]'
        )

        post admin.product_list_product_rules_path(@category.to_global_id),
          params: {
            product_rule: {
              name: 'search',
              operator: 'equals',
              value: '[created_at-30d TOO now]'
            }
          }
        @category.reload

        assert_response(:unprocessable_entity)
        assert_equal(1, @category.product_rules.size)

        patch admin.product_list_product_rule_path(@category.to_global_id, rule),
          params: {
            product_rule: {
              name: 'search',
              operator: 'equals',
              value: '[created_at-30d TOO now]'
            }
          }

        assert_response(:unprocessable_entity)
        assert_equal(1, @category.product_rules.size)
      end

      def test_preview
        get(
          admin.preview_product_list_product_rule_path(
            @category.to_global_id,
            'invalid_id'
          ),
          params: {
            return_to: admin.root_path,
            product_rule: {
              name: 'price',
              operator: 'greater_than',
              value: '10'
            }
          }
        )
        assert_response(:ok)

        rule = @category.product_rules.create!(
          name: 'price',
          operator: 'greater_than',
          value: '10'
        )

        get(
          admin.preview_product_list_product_rule_path(
            @category.to_global_id,
            rule
          ),
          params: {
            return_to: admin.root_path,
            product_rule: {
              name: 'search',
              operator: 'equals',
              value: 'foo'
            }
          }
        )
        assert_response(:ok)
      end
    end
  end
end
