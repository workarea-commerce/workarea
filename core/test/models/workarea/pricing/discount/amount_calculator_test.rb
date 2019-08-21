require 'test_helper'

module Workarea
  module Pricing
    class Discount
      class AmountCalculatorTest < TestCase
        def test_calculate_when_percentage
          discount = OrderTotal.new(amount_type: 'percent')
          calculator = AmountCalculator.new(discount)

          discount.amount = 10
          assert_equal(1.to_m, calculator.calculate(10.to_m))

          discount.amount = 25
          assert_equal(2.5.to_m, calculator.calculate(10.to_m))
        end

        def test_calculate_when_flat_amount
          discount = OrderTotal.new(amount_type: 'flat')
          calculator = AmountCalculator.new(discount)

          discount.amount = 1
          assert_equal(1.to_m, calculator.calculate(10.to_m))

          discount.amount = 2
          assert_equal(2.to_m, calculator.calculate(10.to_m))
        end
      end
    end
  end
end
