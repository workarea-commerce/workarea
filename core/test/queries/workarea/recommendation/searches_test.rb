require 'test_helper'

module Workarea
  module Recommendation
    class SearchesTest < TestCase
      def test_find
        Recommendation::UserActivity.create!(searches: %w(foo bars))
        Recommendation::UserActivity.create!(searches: %w(foo @#$%))
        2.times { Recommendation::UserActivity.create!(searches: %w(foos baz)) }

        ProcessSearchRecommendations.new.perform

        assert_equal([], Searches.find('!#@$%'))
        assert_equal([], Searches.find('fooed'))

        Metrics::SearchByWeek.create!(query_id: 'baz', query_string: 'baz', orders: 1)
        Metrics::SearchByWeek.create!(query_id: 'bar', orders: 2)

        assert_equal(%w(baz), Searches.find('fooed'))
      end
    end
  end
end
