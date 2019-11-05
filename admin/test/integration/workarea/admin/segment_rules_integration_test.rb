require 'test_helper'

module Workarea
  module Admin
    class SegmentRulesIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      setup :setup_segment

      def setup_segment
        @segment = create_segment(rules: [])
      end

      def test_create
        post admin.segment_rules_path(@segment),
          params: { rule_type: 'orders', rule: { minimum: '', maximum: 5 } }

        assert_equal(1, @segment.reload.rules.size)
        assert_equal(Segment::Rules::Orders, @segment.rules.first.class)
        assert_nil(@segment.rules.first.minimum)
        assert_equal(5, @segment.rules.first.maximum)
      end

      def test_update
        rule = @segment.rules.create!({ maximum: 5 }, Segment::Rules::Orders)

        patch admin.segment_rule_path(@segment, rule),
          params: { rule: { minimum: 1, maximum: 5 } }

        assert_equal(1, @segment.reload.rules.size)
        assert_equal(Segment::Rules::Orders, @segment.rules.first.class)
        assert_equal(1, @segment.rules.first.minimum)
        assert_equal(5, @segment.rules.first.maximum)
      end

      def test_destroy
        rule = @segment.rules.create!({ maximum: 5 }, Segment::Rules::Orders)
        delete admin.segment_rule_path(@segment, rule)
        assert_equal(0, @segment.reload.rules.size)
      end

      def test_geolocation_options
        get admin.geolocation_options_segment_rules_path(q: 'penn', format: 'json')
        results = JSON.parse(response.body)['results']
        assert_equal([{ 'label' => 'Pennsylvania, US', 'value' => 'US-PA' }], results)
      end
    end
  end
end
