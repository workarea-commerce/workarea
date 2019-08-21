require 'test_helper'

module Workarea
  module Admin
    class CreateSegmentsIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_creates_segments
        post admin.create_segments_path, params: { segment: { name: 'foo bar' } }

        assert_equal(1, Segment.count)
        assert_equal('foo bar', Segment.desc(:created_at).first.name)
      end

      def test_updates_segments
        segment = create_segment(name: 'Custom Segment')

        post admin.create_segments_path,
          params: { id: segment.id, segment: { name: 'foo bar' } }

        assert_equal(1, Segment.count)
        assert_equal('foo bar', Segment.first.name)
      end
    end
  end
end
