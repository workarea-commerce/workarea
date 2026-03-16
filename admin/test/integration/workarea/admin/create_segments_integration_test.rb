require 'test_helper'

module Workarea
  module Admin
    class CreateSegmentsIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_new_rule_rejects_unknown_rule_type
        segment = create_segment(rules: [])

        get admin.new_rule_create_segment_path(segment),
          params: { rule_type: 'kernel' }

        assert_equal(422, response.status)
      end

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
