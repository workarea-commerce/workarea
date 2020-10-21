require 'test_helper'

module Workarea
  class BulkAction
    class ProductEdit < BulkAction
      class PriceChange
        class AmountTest < TestCase
          setup do
            @current = 10.to_m
          end

          def test_increase_by_percentage
            amount = Amount.new(
              @current,
              action: 'increase',
              type: 'percentage',
              amount: '10'
            )

            assert_equal(11.to_m, amount.to_m)
            assert(amount.apply?)
          end

          def test_decrease_by_percentage
            amount = Amount.new(
              @current,
              action: 'decrease',
              type: 'percentage',
              amount: '10'
            )

            assert_equal(9.to_m, amount.to_m)
            assert(amount.apply?)
          end

          def test_increase_by_flat_amount
            amount = Amount.new(
              @current,
              action: 'increase',
              type: 'flat',
              amount: '10'
            )

            assert_equal(20.to_m, amount.to_m)
            assert(amount.apply?)
          end

          def test_decrease_by_flat_amount
            amount = Amount.new(
              @current,
              action: 'decrease',
              type: 'flat',
              amount: '10'
            )

            assert_equal(0.to_m, amount.to_m)
            assert(amount.apply?)
          end

          def test_set_to_percentage_of_current
            amount = Amount.new(
              @current,
              action: 'set',
              type: 'percentage',
              amount: '10'
            )

            assert_equal(1.to_m, amount.to_m)
            assert(amount.apply?)
          end

          def test_set_flat_amount
            amount = Amount.new(
              @current,
              action: 'set',
              type: 'flat',
              amount: '25'
            )

            assert_equal(25.to_m, amount.to_m)
            refute(amount.apply?)
          end
        end
      end
    end
  end
end
