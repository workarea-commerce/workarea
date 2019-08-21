require 'test_helper'

module Workarea
  module Admin
    class DiscountViewModelTest < TestCase
      def test_compatible_discounts_should_create_a_array_of_ids_and_names
        discount_one = create_product_discount
        discount_two = create_order_total_discount(
          compatible_discount_ids: [discount_one.id]
        )
        view_model = DiscountViewModel.new(discount_two)

        results = view_model.compatible_discounts
        assert_equal(1, results.count)
        assert_equal(discount_one, results.first)
      end
    end
  end
end
