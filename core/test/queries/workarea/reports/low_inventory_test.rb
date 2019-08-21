require 'test_helper'

module Workarea
  module Reports
    class LowInventoryTest < TestCase
      setup :add_data
      teardown :reset_threshold

      def add_data
        @threshold = Workarea.config.low_inventory_threshold
        Workarea.config.low_inventory_threshold = 5

        create_inventory(id: 'foo', available: 5, purchased: 2)
        create_inventory(id: 'bar', available: 4, purchased: 3)
        create_inventory(id: 'baz', available: 3, purchased: 4)
        create_inventory(id: 'qux', available: 1, purchased: 5)
      end

      def reset_threshold
        Workarea.config.low_inventory_threshold = @threshold
      end

      def test_filtering
        report = LowInventory.new
        assert_equal(3, report.count)

        ids = report.results.map { |r| r['_id'] }
        assert_includes(ids, 'bar')
        assert_includes(ids, 'baz')
        assert_includes(ids, 'qux')
      end

      def test_sorting
        report = LowInventory.new(sort_by: 'available', sort_direction: 'asc')
        assert_equal('qux', report.results.first['_id'])

        report = LowInventory.new(sort_by: 'available', sort_direction: 'desc')
        assert_equal('bar', report.results.first['_id'])

        report = LowInventory.new(sort_by: 'purchased', sort_direction: 'asc')
        assert_equal('bar', report.results.first['_id'])

        report = LowInventory.new(sort_by: 'purchased', sort_direction: 'desc')
        assert_equal('qux', report.results.first['_id'])
      end
    end
  end
end
