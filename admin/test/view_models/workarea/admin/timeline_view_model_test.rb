require 'test_helper'

module Workarea
  module Admin
    class TimelineViewModelTest < TestCase
      setup do
        @releasable = create_page
      end

      def test_upcoming_changesets
        release = create_release(name: 'Foo', publish_at: 3.days.from_now)
        release.as_current { @releasable.update_attributes!(name: 'Changed') }

        view_model = TimelineViewModel.new(@releasable)
        assert_equal(view_model.upcoming_changesets.length, 1)
        assert_equal(view_model.upcoming_changesets.first.release_id, release.id)

        release = create_release(name: 'Bar', publish_at: 4.days.from_now)
        release.as_current { @releasable.update_attributes!(name: 'Changed Again') }

        view_model = TimelineViewModel.new(@releasable)
        assert_equal(view_model.upcoming_changesets.length, 2)
        assert_equal(view_model.upcoming_changesets.second.release_id, release.id)

        release = create_release(name: 'Baz')
        release.as_current { @releasable.update_attributes!(name: 'Changed') }

        view_model = TimelineViewModel.new(@releasable)
        assert_equal(view_model.upcoming_changesets.length, 2)

        release = create_release(name: 'Foo', published_at: 3.days.ago)
        release.as_current { @releasable.update_attributes!(name: 'Changed') }

        view_model = TimelineViewModel.new(@releasable)
        assert_equal(view_model.upcoming_changesets.length, 2)

        assert_equal('Foo', view_model.upcoming_changesets.first.release.name)
        assert_equal('Bar', view_model.upcoming_changesets.last.release.name)
      end

      def test_upcoming_changesets_with_content
        release = create_release(publish_at: 1.day.from_now)
        content = Content.for(@releasable)
        release.as_current { content.update_attributes!(browser_title: 'Foo') }

        view_model = TimelineViewModel.new(@releasable)
        assert_equal(view_model.upcoming_changesets.length, 1)
        assert_equal(view_model.upcoming_changesets.first.release_id, release.id)
      end

      def test_empty
        view_model = TimelineViewModel.new(@releasable)
        assert(view_model.empty?)

        release = create_release(name: 'Foo', publish_at: 3.days.from_now)
        release.as_current { @releasable.update_attributes!(name: 'Changed') }
        view_model = TimelineViewModel.new(@releasable)
        refute(view_model.empty?)

        release.destroy
        view_model = TimelineViewModel.new(@releasable)
        assert(view_model.empty?)

        Mongoid::AuditLog.record { @releasable.update_attributes!(name: 'Changed') }
        view_model = TimelineViewModel.new(@releasable)
        refute(view_model.empty?)
      end

      def test_price_override_entry
        user = create_user
        order = Order.new

        timeline = OrderTimelineViewModel.new(OrderViewModel.wrap(order))
        assert(timeline.entries.none?)

        override = Pricing::Override.create!(id: order.id, created_by_id: user.id)
        timeline = OrderTimelineViewModel.new(OrderViewModel.wrap(order))
        assert(timeline.entries.none?)

        override.update_attributes!(subtotal_adjustment: 10.to_m)
        timeline = OrderTimelineViewModel.new(OrderViewModel.wrap(order))
        assert(timeline.entries.one?)
        assert_equal(:price_overridden, timeline.entries.first.slug)
        assert_equal(user, timeline.entries.first.modifier)
        assert_equal(override, timeline.entries.first.model)
      end
    end
  end
end
