require 'test_helper'

module Workarea
  module Pricing
    class PriceDistributorTest < TestCase
      def test_results
        units = [{ id: '1234', price: 0 }]
        distributor = PriceDistributor.new(0, units)
        assert_equal({ '1234' => 0.to_m }, distributor.results)

        units = [
          { id: '1', price: 43.to_m },
          { id: '2', price: 43.to_m },
          { id: '3', price: 54.to_m },
          { id: '4', price: 54.to_m },
          { id: '5', price: 108.to_m },
          { id: '6', price: 0.to_m }
        ]

        distributor = PriceDistributor.new(3.to_m, units)
        assert_equal(3.to_m, distributor.results.values.sum)
      end

      def test_results_with_a_negative_value
        units = [
          { id: '1', price: 10.to_m },
          { id: '2', price: 20.to_m },
          { id: '3', price: 30.to_m },
          { id: '4', price: 0.to_m }
        ]

        results = PriceDistributor.new(-6.to_m, units).results
        assert_equal(-1.to_m, results['1'])
        assert_equal(-2.to_m, results['2'])
        assert_equal(-3.to_m, results['3'])
        assert_equal(0.to_m, results['4'])
      end
    end
  end
end
