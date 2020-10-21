require 'test_helper'

module Workarea
  class BulkAction
    class ProductEdit < BulkAction
      class PriceChangeTest < TestCase
        setup :setup_price_changes

        def setup_price_changes
          @pricing = create_pricing_sku
          @generic_price = @pricing.prices.create!(
            regular: 10.to_m,
            sale: 8.to_m
          )
          @tiered_price = @pricing.prices.create!(
            regular: 5.to_m,
            sale: 4.to_m,
            min_quantity: 2
          )
        end

        def test_set_to_flat_amount
          generic_change = PriceChange.new(
            @generic_price,
            regular: {
              action: 'set',
              type: 'flat',
              amount: '9'
            }
          )
          tiered_change = PriceChange.new(
            @tiered_price,
            regular: {
              action: 'set',
              type: 'flat',
              amount: '9'
            }
          )
          generic_changes = generic_change.attributes

          assert_equal(9.to_m, generic_changes[:regular])
          refute(generic_changes.key?(:sale))
          assert_empty(tiered_change.attributes)
        end

        def test_increase_by_percentage
          generic_change = PriceChange.new(
            @generic_price,
            regular: {
              action: 'increase',
              type: 'percentage',
              amount: '10'
            }
          )
          tiered_change = PriceChange.new(
            @tiered_price,
            regular: {
              action: 'increase',
              type: 'percentage',
              amount: '10'
            }
          )
          generic_changes = generic_change.attributes
          tiered_changes = tiered_change.attributes

          assert_equal(11.to_m, generic_changes[:regular])
          assert_equal(5.5.to_m, tiered_changes[:regular])
          refute(generic_changes.key?(:sale))
          refute(tiered_changes.key?(:sale))
        end

        def test_decrease_by_percentage
          generic_change = PriceChange.new(
            @generic_price,
            regular: {
              action: 'decrease',
              type: 'percentage',
              amount: '10'
            }
          )
          tiered_change = PriceChange.new(
            @tiered_price,
            regular: {
              action: 'decrease',
              type: 'percentage',
              amount: '10'
            }
          )
          generic_changes = generic_change.attributes
          tiered_changes = tiered_change.attributes

          assert_equal(9.to_m, generic_changes[:regular])
          assert_equal(4.5.to_m, tiered_changes[:regular])
          refute(generic_changes.key?(:sale))
          refute(tiered_changes.key?(:sale))
        end

        def test_increase_by_flat_amount
          generic_change = PriceChange.new(
            @generic_price,
            regular: {
              action: 'increase',
              type: 'flat',
              amount: '10'
            }
          )
          tiered_change = PriceChange.new(
            @tiered_price,
            regular: {
              action: 'increase',
              type: 'flat',
              amount: '10'
            }
          )
          generic_changes = generic_change.attributes
          tiered_changes = tiered_change.attributes

          assert_equal(20.to_m, generic_changes[:regular])
          assert_equal(15.to_m, tiered_changes[:regular])
          refute(generic_changes.key?(:sale))
          refute(tiered_changes.key?(:sale))
        end

        def test_decrease_by_flat_amount
          generic_change = PriceChange.new(
            @generic_price,
            sale: {
              action: 'decrease',
              type: 'flat',
              amount: '1'
            }
          )
          tiered_change = PriceChange.new(
            @tiered_price,
            sale: {
              action: 'decrease',
              type: 'flat',
              amount: '1'
            }
          )
          generic_changes = generic_change.attributes
          tiered_changes = tiered_change.attributes

          assert_equal(7.to_m, generic_changes[:sale])
          assert_equal(3.to_m, tiered_changes[:sale])
          refute(generic_changes.key?(:regular))
          refute(tiered_changes.key?(:regular))
        end
      end
    end
  end
end
