require 'test_helper'

module Workarea
  module Metrics
    class CalculatePercentilesTest < TestCase
      def test_simple_data
        create_data(*0..99)
        results = find_results

        assert_equal(100, results.size)
        assert_equal(1, results['1'])
        assert_equal(99, results['99'])
      end

      def test_smaller_data
        create_data(15, 20, 25, 40, 50)
        results = find_results

        assert_equal(100, results.size)
        assert_equal(15, results['5'])
        assert_equal(20, results['30'])
        assert_equal(25, results['40'])
        assert_equal(25, results['50'])
        assert_equal(50, results['99'])
      end

      def test_clean_data
        create_data(12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48)
        assert_equal(36, find_results['65'])
      end

      private

      def create_data(*values)
        values.each do |value|
          ProductForLastWeek.create!(product_id: value, views: value)
        end
      end

      def find_results
        CalculatePercentiles
          .new(ProductForLastWeek.collection, :views)
          .results
      end
    end
  end
end
