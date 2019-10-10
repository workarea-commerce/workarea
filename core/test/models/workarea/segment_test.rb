require 'test_helper'

module Workarea
  class SegmentTest < TestCase
    def test_find_qualifying
      one = create_segment(rules: [Segment::Rules::Orders.new(minimum: 1)])
      two = create_segment(rules: [Segment::Rules::Orders.new(minimum: 2)])
      three = create_segment(rules: [Segment::Rules::Orders.new(minimum: 3)])

      metrics = Metrics::User.create!(id: 'bcrouse@workarea.com')

      visit = create_visit(email: 'bcrouse@workarea.com')
      assert(Segment.find_qualifying(visit).empty?)

      metrics.update_attributes!(orders: 1)
      visit = create_visit(email: 'bcrouse@workarea.com')
      assert_equal([one], Segment.find_qualifying(visit))

      metrics.update_attributes!(orders: 2)
      visit = create_visit(email: 'bcrouse@workarea.com')
      assert_equal([one, two], Segment.find_qualifying(visit))

      metrics.update_attributes!(orders: 3)
      visit = create_visit(email: 'bcrouse@workarea.com')
      assert_equal([one, two, three], Segment.find_qualifying(visit))
    end

    def test_current
      assert_equal([], Segment.current)

      segment = create_segment
      Segment.with_current(segment) { assert_equal([segment], Segment.current) }
      assert_equal([], Segment.current)

      Segment.with_current([segment]) { assert_equal([segment], Segment.current) }
      assert_equal([], Segment.current)

      assert_raises { Segment.with_current(segment) { raise 'foo' } }
      assert_equal([], Segment.current)
    end

    def test_with_current_returns_the_value_from_the_block
      segment = create_segment
      result = Segment.with_current(segment) { 'foo' }
      assert_equal('foo', result)
    end

    def test_qualifies
      segment = create_segment(
        rules: [
          Segment::Rules::Orders.new(minimum: 2),
          Segment::Rules::Sessions.new(minimum: 5)
        ]
      )

      metrics = Metrics::User.create!(id: 'bcrouse@workarea.com')

      visit = create_visit(email: 'bcrouse@workarea.com')
      refute(segment.qualifies?(visit))

      metrics.update_attributes!(orders: 2)
      visit = create_visit(email: 'bcrouse@workarea.com')
      refute(segment.qualifies?(visit))

      visit = create_visit(email: 'bcrouse@workarea.com', sessions: 2)
      refute(segment.qualifies?(visit))

      visit = create_visit(email: 'bcrouse@workarea.com', sessions: 5)
      assert(segment.qualifies?(visit))
    end

    def test_validates_max_segments
      15.times { create_segment }

      segment = Segment.new
      refute(segment.valid?)
      assert_includes(segment.errors[:base], t('workarea.errors.messages.max_allowed_segments'))
    end
  end
end
