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
          assert(TrafficReferrer.new(source: %w(Google)).qualifies?(visit))
          refute(TrafficReferrer.new(source: %w(Yahoo!)).qualifies?(visit))
          assert(TrafficReferrer.new(medium: 'Search').qualifies?(visit))
          refute(TrafficReferrer.new(medium: 'Social').qualifies?(visit))
          assert(TrafficReferrer.new(url: 'google').qualifies?(visit))
          refute(TrafficReferrer.new(url: 'twitter').qualifies?(visit))

          visit = create_visit('HTTP_REFERER' => 'https://www.facebook.com/')
          assert(TrafficReferrer.new(source: %w(Facebook)).qualifies?(visit))
          refute(TrafficReferrer.new(source: %w(Google)).qualifies?(visit))
          assert(TrafficReferrer.new(medium: 'Social').qualifies?(visit))
          refute(TrafficReferrer.new(medium: 'Search').qualifies?(visit))
          assert(TrafficReferrer.new(url: 'www').qualifies?(visit))
          refute(TrafficReferrer.new(url: 'facebook$').qualifies?(visit))
        end
      end
    end
  end
end
