require 'test_helper'

module Workarea
  class Segment
    module Rules
      class SessionsTest < TestCase
        def test_qualifies?
          visit = create_visit
          refute(Sessions.new.qualifies?(visit))
          refute(Sessions.new(minimum: 1).qualifies?(visit))
          refute(Sessions.new(minimum: 1).qualifies?(create_visit(sessions: 0)))
          assert(Sessions.new(minimum: 1).qualifies?(create_visit(sessions: 1)))
          assert(Sessions.new(minimum: 1).qualifies?(create_visit(sessions: 2)))
          assert(Sessions.new(maximum: 2).qualifies?(create_visit(sessions: 0)))
          assert(Sessions.new(maximum: 2).qualifies?(create_visit(sessions: 1)))
          assert(Sessions.new(maximum: 2).qualifies?(create_visit(sessions: 2)))
          refute(Sessions.new(maximum: 2).qualifies?(create_visit(sessions: 3)))
          refute(Sessions.new(minimum: 1, maximum: 2).qualifies?(create_visit(sessions: 3)))
          refute(Sessions.new(minimum: 1, maximum: 2).qualifies?(create_visit(sessions: 0)))
          assert(Sessions.new(minimum: 1, maximum: 2).qualifies?(create_visit(sessions: 1)))
          assert(Sessions.new(minimum: 1, maximum: 2).qualifies?(create_visit(sessions: 2)))
        end
      end
    end
  end
end
