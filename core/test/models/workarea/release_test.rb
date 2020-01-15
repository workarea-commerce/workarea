require 'test_helper'

module Workarea
  class ReleaseTest < TestCase
    def create_release(overrides = {})
      attributes = { name: 'Foo' }.merge(overrides)
      release = Release.new(attributes)
      release.save!(validate: false)
      release
    end

    def test_validates_a_publish_at_is_in_the_future_if_not_published
      release = Release.new(publish_at: Time.current - 1.day)
      refute(release.valid?)
      assert(release.errors[:publish_at].present?)
    end

    def test_current_uses_the_specified_release
      assert_nil(Release.current)

      release = create_release
      Release.with_current(release.id) do
        assert_equal(release.id, Release.current.id)
      end

      assert_nil(Release.current)

      assert_raises do
        Release.with_current(release.id) { raise 'foo' }
      end

      assert_nil(Release.current)
    end

    def test_current_returns_the_value_from_the_block
      release = create_release
      result = Release.with_current(release.id) { 'foo' }
      assert_equal('foo', result)
    end

    def test_current_ignores_an_non_existing_release
      Release.with_current('asdfasdf') do
        assert_nil(Release.current)
      end
    end

    def test_scheduled
      blank = create_release(publish_at: nil)
      first = create_release(publish_at: 1.day.from_now)
      second = create_release(publish_at: 2.days.from_now)
      third = create_release(publish_at: 3.days.from_now)

      assert_equal([first, second, third], Release.scheduled.desc(:publish_at))
      assert_equal([first], Release.scheduled(before: 2.days.from_now))
    end

    def test_unscheduled_does_not_return_scheduled_or_published_releases
      create_release(publish_at: Time.current + 1.week, published_at: nil)
      create_release(publish_at: nil, published_at: Time.current - 1.week)
      unscheduled_release = create_release(publish_at: nil, published_at: nil)

      assert_equal([unscheduled_release], Release.unscheduled.to_a)
    end

    def test_upcoming_puts_unscheduled_at_the_top
      release_2 = create_release(publish_at: Time.current + 1.week, published_at: nil)
      release_3 = create_release(publish_at: Time.current + 3.days, published_at: nil)
      release_0 = create_release(publish_at: nil, published_at: nil)
      release_1 = create_release(publish_at: Time.current + 2.weeks, published_at: nil)
      create_release(publish_at: Time.current - 1.week, published_at: nil)

      result = Release.upcoming.to_a
      assert_equal([release_0, release_1, release_2, release_3], result)
    end

    def test_upcoming_sorts_by_time
      release_2 = create_release(publish_at: Time.current + 1.week, published_at: nil)
      release_3 = create_release(publish_at: Time.current + 3.days, published_at: nil)
      release_1 = create_release(publish_at: Time.current + 2.weeks, published_at: nil)
      create_release(publish_at: Time.current - 1.week, published_at: nil)

      result = Release.upcoming.to_a
      assert_equal([release_1, release_2, release_3], result)
    end

    def test_upcoming_includes_rescheduled_releases
      release_1 = create_release(publish_at: Time.current + 2.weeks, published_at: 1.minute.ago)
      release_2 = create_release(publish_at: Time.current + 1.week, published_at: nil)
      release_3 = create_release(publish_at: Time.current + 3.days, published_at: nil)
      create_release(publish_at: Time.current - 1.week, published_at: nil)

      result = Release.upcoming.to_a
      assert_equal([release_1, release_2, release_3], result)
    end

    def test_published_within_includes_releases_within_a_specified_range
      create_release(publish_at: 1.month.from_now, published_at: nil)
      release_2 = create_release(publish_at: 1.day.from_now, published_at: nil)

      result = Release.published_within(Time.current, 2.days.from_now)
      assert_equal([release_2], result)
    end

    def test_is_sorted_by_published_publish_time
      release_3 = create_release(published_at: nil, publish_at: 3.hours.from_now)
      release_2 = create_release(published_at: nil, publish_at: 1.hour.from_now)
      release_1 = create_release(published_at: 2.hours.from_now, publish_at: nil)

      result = Release.published_within(Time.current, Time.current + 4.hours)
      assert_equal([release_1, release_2, release_3], result)
    end

    def test_sort_by_publish
      first = create_release(publish_at: 1.day.from_now)
      second = create_release(publish_at: 2.days.from_now)
      third = create_release(publish_at: 3.days.from_now)

      assert_equal([first, second, third], Release.all.sort_by_publish)

      fourth = create_release(publish_at: first.publish_at)
      assert_equal([first, fourth, second, third], Release.all.sort_by_publish)
    end

    def test_publish_sets_publish_at_to_nil
      release = create_release(publish_at: 1.week.from_now)
      release.publish!
      release.reload
      assert(release.publish_at.blank?)
    end

    def test_scheduled
      release = Release.new
      refute(release.scheduled?)

      release = Release.new(publish_at: 4.days.from_now)
      refute(release.scheduled?)

      release = create_release(publish_at: nil)
      refute(release.scheduled?)

      release = create_release(publish_at: nil)
      release.publish_at = 4.days.from_now
      refute(release.scheduled?)

      release = create_release(publish_at: 4.days.from_now)
      assert(release.scheduled?)
    end

    def test_publishing_on_deleted_models
      page = create_page(name: 'Foo')
      release = create_release

      release.as_current do
        page.update_attributes!(name: 'Bar')
      end

      Content::Page.delete_all # leave changesets with no model
      release.publish!

      assert(release.published?)
    end

    def test_ordered_changesets
      release = create_release
      [
        { releasable_type: 'Workarea::Catalog::Category', releasable_id: '123' },
        { releasable_type: 'Workarea::Catalog::Product', releasable_id: 'PROD1' },
        { releasable_type: 'Workarea::Catalog::Variant', releasable_id: 'VAR1' },
        { releasable_type: 'Workarea::Content::Page', releasable_id: 'PAGE1' },
        { releasable_type: 'Workarea::Navigation::Menu', releasable_id: 'NAV1' },
        { releasable_type: 'Workarea::Content', releasable_id: 'CON1' },
        { releasable_type: 'Workarea::Search::Customization', releasable_id: 'CUS1' },
        { releasable_type: 'Workarea::Content::Block', releasable_id: 'BLC1' }
      ].each { |changeset| release.changesets.build(changeset) }

      assert_equal(
        %w(
          Workarea::Catalog::Variant
          Workarea::Catalog::Product
          Workarea::Content::Block
          Workarea::Content
          Workarea::Content::Page
          Workarea::Catalog::Category
          Workarea::Search::Customization
          Workarea::Navigation::Menu
        ),
        release.ordered_changesets.map(&:releasable_type)
      )
    end
  end
end
