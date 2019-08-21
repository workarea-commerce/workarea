require 'test_helper'

module Workarea
  module Admin
    class ReleaseViewModelTest < TestCase
      setup :set_release

      def set_release
        @release = create_release
      end

      def test_published_on_date_returns_true_if_the_release_was_published_on_the_supplied_date
        @release.published_at = Time.current
        @release.save!

        view_model = ReleaseViewModel.new(@release)
        assert(view_model.published_on_date?(Date.current))
      end

      def test_published_on_returns_true_if_the_release_was_scheduled_for_the_supplied_date
        @release.publish_at = Time.current + 1.day
        @release.save!

        view_model = ReleaseViewModel.new(@release)
        assert(view_model.published_on_date?(Date.current + 1.day))
      end

      def test_ended_on_date
        @release.published_at = Time.current
        @release.undo_at = Time.current + 1.month
        @release.save!

        view_model = ReleaseViewModel.new(@release)
        assert(view_model.ended_on_date?(Date.current + 1.month))
      end

      def test_content_release
        view_model = ReleaseViewModel.new(@release)
        assert(view_model.content_release?)
      end

      def test_publish_time_returns_the_rescheduled_publish_time
        now = Time.current

        @release.published_at = now - 1.month
        @release.publish_at = now + 1.month
        @release.save!

        view_model = ReleaseViewModel.new(@release)
        assert_equal(now + 1.month, view_model.publish_time)
      end

      def test_publish_time_returns_the_time_it_was_published_if_not_rescheduled
        now = Time.current

        @release.published_at = now - 1.month
        @release.save!

        view_model = ReleaseViewModel.new(@release)
        assert_equal(now - 1.month, view_model.publish_time)
      end

      def test_nil_changesets_are_excluded_from_changesets_with_releasable
        pricing_sku = create_pricing_sku(prices: [{ regular: 3, sale: 1, min_quantity: 1 }])
        releasable = pricing_sku.prices.first
        releasable.changesets.create!(
          release: @release,
          document_path: releasable.document_path
        )

        view_model = ReleaseViewModel.new(@release)
        assert_equal(view_model.changesets_with_releasable.length, 1)

        pricing_sku.prices.first.delete
        view_model = ReleaseViewModel.new(@release)
        assert_empty(view_model.changesets_with_releasable)
      end
    end
  end
end
