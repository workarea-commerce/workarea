require 'test_helper'

module Workarea
  module Admin
    class DiscountRulesViewModelTest < TestCase
      def test_all_discounts
        Workarea.config.discount_application_order.each do |class_name|
          discount = class_name.constantize.new
          assert_nothing_raised do
            DiscountRulesViewModel.new(discount).to_h
          end
        end
      end

      def test_ignores_base_fields
        discount = create_buy_some_get_some_discount
        view_model = DiscountRulesViewModel.new(discount)

        assert(view_model.to_h.keys.exclude?('_id'))
        assert(view_model.to_h.keys.exclude?('created_at'))
        assert(view_model.to_h.keys.exclude?('updated_at'))
      end

      def test_amount
        discount = create_category_discount(amount: 5, amount_type: 'percent')
        view_model = DiscountRulesViewModel.new(discount)
        assert_equal('5%', view_model.amount)

        discount = create_category_discount(amount: 5, amount_type: 'flat')
        view_model = DiscountRulesViewModel.new(discount)
        assert_equal("#{Money.default_currency.symbol}5.00", view_model.amount)
      end

      def test_item_quantity
        discount = create_product_attribute_discount(item_quantity: 0)
        view_model = DiscountRulesViewModel.new(discount)
        assert_nil(view_model.item_quantity)

        discount = create_product_attribute_discount(item_quantity: 1)
        view_model = DiscountRulesViewModel.new(discount)
        assert_equal(1, view_model.item_quantity)
      end

      def test_product_ids
        products = [create_product(name: 'Foo'), create_product(name: 'Bar')]
        product_ids = products.map(&:id) + ['foo']
        discount = create_product_discount(product_ids: product_ids)
        view_model = DiscountRulesViewModel.new(discount)

        assert_equal('Bar + 1 more', view_model.product_ids)
        refute_includes(view_model.to_h.keys, 'product_ids')
        assert_includes(view_model.to_h.keys, 'Products')
      end

      def test_category_ids
        categories = [create_category(name: 'Foo'), create_category(name: 'Bar')]
        category_ids = categories.map(&:id) + ['foo']
        discount = create_category_discount(category_ids: category_ids)
        view_model = DiscountRulesViewModel.new(discount)

        assert_equal('Bar + 1 more', view_model.category_ids)
        refute_includes(view_model.to_h.keys, 'category_ids')
        assert_includes(view_model.to_h.keys, 'Categories')
      end

      def test_promo_codes
        discount = create_order_total_discount(promo_codes: %w(fOo Bar))
        view_model = DiscountRulesViewModel.new(discount)
        assert_equal('FOO, BAR', view_model.promo_codes)
      end

      def test_order_total_operator
        discount = create_order_total_discount(
          order_total_operator: 'greater_than',
          order_total: nil
        )

        view_model = DiscountRulesViewModel.new(discount)
        assert_nil(view_model.order_total_operator)

        discount.update_attributes!(order_total: 0)
        assert_nil(view_model.order_total_operator)

        discount.update_attributes!(order_total: 100)
        assert_equal('greater than', view_model.order_total_operator)
      end

      def test_order_total
        discount = create_order_total_discount(
          order_total_operator: 'greater_than',
          order_total: nil
        )

        view_model = DiscountRulesViewModel.new(discount)
        assert_nil(view_model.order_total)

        discount.update_attributes!(order_total: 0)
        assert_nil(view_model.order_total)

        discount.update_attributes!(order_total: 100)
        assert_equal(100.to_m, view_model.order_total)
      end

      def test_generated_codes_id
        code_list = create_code_list(name: 'Foo')
        discount = create_order_total_discount(generated_codes_id: nil)
        view_model = DiscountRulesViewModel.new(discount)

        assert_nil(view_model.generated_codes_id)

        discount.update_attributes!(generated_codes_id: code_list.id)
        assert_equal('Foo', view_model.generated_codes_id)

        code_list.destroy
        assert_nil(view_model.generated_codes_id)
      end
    end
  end
end
