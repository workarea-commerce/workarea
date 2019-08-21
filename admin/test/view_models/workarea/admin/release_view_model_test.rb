require 'test_helper'

module Workarea
  module Admin
    class ReleaseViewModelTest < TestCase
      def test_calendar_on_returns_the_rescheduled_date
        release = create_release

        release.published_at = Date.current - 1.month
        release.publish_at = Date.current + 1.month
        view_model = ReleaseViewModel.wrap(release)
        assert_equal(Date.current + 1.month, view_model.calendar_on)

        release.publish_at = nil
        view_model = ReleaseViewModel.wrap(release)
        assert_equal(Date.current - 1.month, view_model.calendar_on)
      end

      def test_nil_changesets_are_excluded_from_changesets_with_releasable
        release = create_release
        pricing_sku = create_pricing_sku(prices: [{ regular: 3, sale: 1, min_quantity: 1 }])
        releasable = pricing_sku.prices.first
        releasable.changesets.create!(
          release: release,
          document_path: releasable.document_path
        )

        view_model = ReleaseViewModel.new(release)
        assert_equal(view_model.changesets_with_releasable.length, 1)

        pricing_sku.prices.first.delete
        view_model = ReleaseViewModel.new(release)
        assert_empty(view_model.changesets_with_releasable)
      end
    end
  end
end
