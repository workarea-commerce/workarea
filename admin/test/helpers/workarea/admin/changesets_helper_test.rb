require 'test_helper'

module Workarea
  module Admin
    class ChangesetsHelperTest < ViewTest
      def test_releasable_icon_path
        assert_equal(
          releasable_icon_path(nil),
          'workarea/admin/icons/release.svg'
        )

        assert_equal(
          releasable_icon_path('product'),
          'workarea/admin/icons/products.svg'
        )

        assert_equal(
          releasable_icon_path('variants'),
          'workarea/admin/icons/variants.svg'
        )
      end
    end
  end
end
