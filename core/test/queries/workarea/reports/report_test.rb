require 'test_helper'

module Workarea
  module Reports
    class ReportTest < TestCase
      class TestReport
        include Report

        self.reporting_class = Metrics::ProductByDay
        self.sort_fields = %w(foo bar)

        def aggregation
          []
        end
      end

      setup :add_data

      def add_data
        Metrics::ProductByDay.inc(key: { product_id: 'foo' }, orders: 1)
        Metrics::ProductByDay.inc(key: { product_id: 'bar' }, orders: 1)
      end

      def test_starts_at
        blank = TestReport.new
        assert_kind_of(ActiveSupport::TimeWithZone, blank.starts_at)
        assert(blank.starts_at < Time.current)

        blank_time = TestReport.new(starts_at: '')
        assert_kind_of(ActiveSupport::TimeWithZone, blank.starts_at)

        with_time = TestReport.new(starts_at: '2018-11-1 4:00PM')
        assert_equal(Time.zone.parse('2018-11-1'), with_time.starts_at)
      end

      def test_ends_at
        blank = TestReport.new
        assert_kind_of(ActiveSupport::TimeWithZone, blank.ends_at)
        assert(blank.ends_at > Time.current)

        blank_time = TestReport.new(ends_at: '')
        assert_kind_of(ActiveSupport::TimeWithZone, blank.ends_at)

        with_time = TestReport.new(ends_at: '2018-11-1 4:00PM')
        assert(Time.zone.parse('2018-11-1 11:59:59PM') < with_time.ends_at)
        assert(Time.zone.parse('2018-11-2') > with_time.ends_at)
      end

      def test_sort
        assert_equal({ '$sort' => { 'foo' => -1 } }, TestReport.new.sort)

        assert_equal(
          { '$sort' => { 'foo' => -1 } },
          TestReport.new(sort_by: 'asdf').sort
        )

        assert_equal(
          { '$sort' => { 'foo' => 1 } },
          TestReport.new(sort_by: 'foo', sort_direction: 'asc').sort
        )

        assert_equal(
          { '$sort' => { 'foo' => -1 } },
          TestReport.new(sort_direction: 'asdf').sort
        )

        assert_equal(
          { '$sort' => { 'bar' => 1 } },
          TestReport.new(sort_by: 'bar', sort_direction: 'asc').sort
        )

        assert_equal(
          { '$sort' => { 'bar' => 1 } },
          TestReport.new('sort_by' => 'bar', 'sort_direction' => 'asc').sort
        )
      end

      def test_results
        Workarea.config.reports_max_results = 1
        report = TestReport.new

        assert_equal(1, report.count)
        assert_equal(1, report.results.size)
      end

      def test_cache_key
        one = TestReport.new
        two = TestReport.new(sort_by: 'foo')
        three = TestReport.new(starts_at: '2018-11-2')

        assert_equal(TestReport.new.cache_key, one.cache_key)
        refute_equal(one.cache_key, two.cache_key)
        refute_equal(one.cache_key, three.cache_key)
        refute_equal(two.cache_key, three.cache_key)
      end
    end
  end
end
