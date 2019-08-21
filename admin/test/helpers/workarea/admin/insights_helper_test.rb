require 'test_helper'

module Workarea
  module Admin
    class InsightsHelperTest < ViewTest
      def test_sparkline_analytics_data_for
        assert_equal([0], sparkline_analytics_data_for(nil))
        assert_equal([0], sparkline_analytics_data_for(''))
        assert_equal([0], sparkline_analytics_data_for([]))

        test = [0, 0, 0]
        assert_equal([0, 0, 0], sparkline_analytics_data_for(test))

        test = [600, 0, 200, 100, 50]
        assert_equal([9, 0, 2, 1, 0], sparkline_analytics_data_for(test))
      end
    end
  end
end
