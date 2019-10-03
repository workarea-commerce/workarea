require 'test_helper'

module Workarea
  class Segment
    module Rules
      class TagsTest < TestCase
        def test_qualifies?
          metrics = Metrics::User.create!(id: 'bcrouse@workarea.com')

          visit = create_visit(email: 'bcrouse@workarea.com')
          refute(Tags.new.qualifies?(visit))

          visit = create_visit(email: 'bcrouse@workarea.com')
          refute(Tags.new(tags: %w(foo)).qualifies?(visit))

          metrics.update!(tags: %w(bar))
          visit = create_visit(email: 'bcrouse@workarea.com')
          refute(Tags.new(tags: %w(foo)).qualifies?(visit))

          metrics.update!(tags: %w(foo))
          visit = create_visit(email: 'bcrouse@workarea.com')
          assert(Tags.new(tags: %w(foo)).qualifies?(visit))
        end
      end
    end
  end
end
