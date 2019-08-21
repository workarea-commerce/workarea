require 'test_helper'

module Workarea
  module Search
    class RangeParameterTest < TestCase
      def test_start
        assert_equal('5', RangeParameter.new('5-10').start)
        assert_equal('*', RangeParameter.new('*-10').start)
        assert_equal('5', RangeParameter.new("'\"5-10").start)
      end

      def test_stop
        assert_equal('10', RangeParameter.new('5-10').stop)
        assert_equal('*', RangeParameter.new('5-*').stop)
        assert_equal('10', RangeParameter.new("5-10'\"").stop)
      end

      def test_to_filter
        assert_equal('5', RangeParameter.new('5-10').to_filter[:gte])
        assert_equal('10', RangeParameter.new('5-10').to_filter[:lt])

        assert_nil(RangeParameter.new('*-10').to_filter[:gte])
        assert_equal('10', RangeParameter.new('*-10').to_filter[:lt])

        assert_equal('5', RangeParameter.new('5-*').to_filter[:gte])
        assert_nil(RangeParameter.new('5-*').to_filter[:lt])
      end
    end
  end
end
