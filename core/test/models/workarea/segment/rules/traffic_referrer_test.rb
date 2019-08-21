require 'test_helper'

module Workarea
  class Segment
    module Rules
      class TrafficReferrerTest < TestCase
        def test_qualifies?
          visit = create_visit
          refute(TrafficReferrer.new.qualifies?(visit))

          visit = create_visit('HTTP_REFERER' => 'http://workarea.com/')
          refute(TrafficReferrer.new.qualifies?(visit))

          visit = create_visit('HTTP_REFERER' => 'https://www.google.com/')
          assert(TrafficReferrer.new(source: 'google').qualifies?(visit))
          assert(TrafficReferrer.new(source: ' Google').qualifies?(visit))
          assert(TrafficReferrer.new(medium: 'Search').qualifies?(visit))
          refute(TrafficReferrer.new(source: 'Facebook ').qualifies?(visit))
          refute(TrafficReferrer.new(source: 'social').qualifies?(visit))

          visit = create_visit('HTTP_REFERER' => 'https://www.facebook.com/')
          refute(TrafficReferrer.new(source: ' Google').qualifies?(visit))
          refute(TrafficReferrer.new(medium: 'search').qualifies?(visit))
          assert(TrafficReferrer.new(source: 'facebook ').qualifies?(visit))
          assert(TrafficReferrer.new(medium: 'Social').qualifies?(visit))
          assert(TrafficReferrer.new(medium: 'Social', source: 'facebook|twitter').qualifies?(visit))
        end
      end
    end
  end
end
