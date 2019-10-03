require 'test_helper'

module Workarea
  class Segment
    module Rules
      class LoggedInTest < TestCase
        def test_qualifies?
          metrics = Metrics::User.create!(id: 'bcrouse@workarea.com')

          visit = create_visit(email: 'bcrouse@workarea.com', logged_in: false)
          refute(LoggedIn.new(logged_in: true).qualifies?(visit))

          visit = create_visit(email: 'bcrouse@workarea.com', logged_in: false)
          assert(LoggedIn.new(logged_in: false).qualifies?(visit))

          visit = create_visit(email: 'bcrouse@workarea.com', logged_in: true)
          assert(LoggedIn.new(logged_in: true).qualifies?(visit))

          visit = create_visit(email: 'bcrouse@workarea.com', logged_in: true)
          refute(LoggedIn.new(logged_in: false).qualifies?(visit))
        end
      end
    end
  end
end
