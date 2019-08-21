require 'test_helper'

module Workarea
  module Reports
    class SearchesWithoutResultsOverTimeTest < TestCase
      def test_by_day
        Metrics::SearchByDay.save_search('bar', 0, at: Time.zone.local(2018, 10, 27))
        Metrics::SearchByDay.save_search('foo', 1, at: Time.zone.local(2018, 10, 27))

        Metrics::SearchByDay.save_search('bar', 0, at: Time.zone.local(2018, 10, 28))
        Metrics::SearchByDay.save_search('foo', 1, at: Time.zone.local(2018, 10, 28))

        Metrics::SearchByDay.save_search('bar', 0, at: Time.zone.local(2018, 10, 29))
        Metrics::SearchByDay.save_search('foo', 1, at: Time.zone.local(2018, 10, 29))

        travel_to Time.zone.local(2018, 10, 30)
        report = SearchesWithoutResultsOverTime.new(group_by: 'day', sort_by: '_id', sort_direction: 'desc')

        assert_equal(3, report.results.length)

        assert_equal(2018, report.results.first['_id']['year'])
        assert_equal(10, report.results.first['_id']['month'])
        assert_equal(29, report.results.first['_id']['day'])
        assert_equal(1, report.results.first['searches'])
        assert_equal(Time.zone.local(2018, 10, 29), report.results.first['starts_at'])

        assert_equal(2018, report.results.second['_id']['year'])
        assert_equal(10, report.results.second['_id']['month'])
        assert_equal(28, report.results.second['_id']['day'])
        assert_equal(1, report.results.second['searches'])
        assert_equal(Time.zone.local(2018, 10, 28), report.results.second['starts_at'])

        assert_equal(2018, report.results.third['_id']['year'])
        assert_equal(10, report.results.third['_id']['month'])
        assert_equal(27, report.results.third['_id']['day'])
        assert_equal(1, report.results.third['searches'])
        assert_equal(Time.zone.local(2018, 10, 27), report.results.third['starts_at'])

        report = SearchesWithoutResultsOverTime.new(group_by: 'day', sort_by: '_id', sort_direction: 'asc')
        assert_equal(3, report.results.length)

        assert_equal(2018, report.results.first['_id']['year'])
        assert_equal(10, report.results.first['_id']['month'])
        assert_equal(27, report.results.first['_id']['day'])

        assert_equal(2018, report.results.second['_id']['year'])
        assert_equal(10, report.results.second['_id']['month'])
        assert_equal(28, report.results.second['_id']['day'])

        assert_equal(2018, report.results.third['_id']['year'])
        assert_equal(10, report.results.third['_id']['month'])
        assert_equal(29, report.results.third['_id']['day'])
      end


      def test_date_ranges
        Metrics::SearchByDay.save_search('bar', 0, at: Time.zone.local(2018, 10, 27))
        Metrics::SearchByDay.save_search('foo', 1, at: Time.zone.local(2018, 10, 27))

        Metrics::SearchByDay.save_search('bar', 0, at: Time.zone.local(2018, 10, 28))
        Metrics::SearchByDay.save_search('foo', 1, at: Time.zone.local(2018, 10, 28))

        Metrics::SearchByDay.save_search('bar', 0, at: Time.zone.local(2018, 10, 29))
        Metrics::SearchByDay.save_search('foo', 1, at: Time.zone.local(2018, 10, 29))

        report = SearchesWithoutResultsOverTime.new(
          group_by: 'day',
          starts_at: '2018-10-28',
          ends_at: '2018-10-28'
        )

        assert_equal(1, report.results.size)
        assert_equal(2018, report.results.first['_id']['year'])
        assert_equal(10, report.results.first['_id']['month'])
        assert_equal(28, report.results.first['_id']['day'])
        assert_equal(1, report.results.first['searches'])
        assert_equal(Time.zone.local(2018, 10, 28), report.results.first['starts_at'])

        report = SearchesWithoutResultsOverTime.new(
          group_by: 'day',
          starts_at: '2018-10-28',
          ends_at: '2018-10-29'
        )

        assert_equal(2, report.results.size)
        assert_equal(2018, report.results.first['_id']['year'])
        assert_equal(10, report.results.first['_id']['month'])
        assert_equal(29, report.results.first['_id']['day'])
        assert_equal(1, report.results.first['searches'])
        assert_equal(Time.zone.local(2018, 10, 29), report.results.first['starts_at'])

        assert_equal(2018, report.results.second['_id']['year'])
        assert_equal(10, report.results.second['_id']['month'])
        assert_equal(28, report.results.second['_id']['day'])
        assert_equal(1, report.results.second['searches'])
        assert_equal(Time.zone.local(2018, 10, 28), report.results.second['starts_at'])
      end
    end
  end
end
