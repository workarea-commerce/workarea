require 'test_helper'

module Workarea
  class Segment
    class LifeCycleTest < TestCase
      class FooSegment < Segment
        include LifeCycle
        self.default_rules = [Rules::Orders.new(maximum: 0)]
      end

      def test_name_given
        life_cycle = FooSegment.instance # create it
        assert_equal('Foo Segment', life_cycle.name)
      end

      def test_cannot_destroy
        life_cycle = FooSegment.instance # create it

        assert_no_difference 'Segment.count' do
          refute(life_cycle.destroy)
        end

        assert_nothing_raised do
          life_cycle.reload
        end
      end
    end
  end
end
