require 'test_helper'

module Workarea
  module Admin
    class SegmentOverridesIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_creates_segment_overrides
        segment_one = create_segment
        segment_two = create_segment
        post admin.segment_override_path,
          params: {
            segment_ids: { segment_one.id => 'true', segment_two.id => 'false' },
            return_to: '/foo'
          }
        assert_equal([segment_one.id], session[:segment_ids])
        assert_redirected_to('/foo')

        post admin.segment_override_path,
          params: {
            segment_ids: { segment_one.id => 'false', segment_two.id => 'false' }
          }
        assert_nil(session[:segment_ids])
        assert_redirected_to(storefront.root_path)
      end
    end
  end
end
