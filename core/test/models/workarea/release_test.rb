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

    def test_scheduled_before
      one_week_from_now = 1.week.from_now

      one = create_release(publish_at: one_week_from_now)
      two = create_release(publish_at: nil)
      three = create_release(publish_at: 8.days.from_now)
      four = create_release(publish_at: 6.days.from_now)
      five = create_release(publish_at: one_week_from_now)
      six = create_release(publish_at: 4.days.from_now)

      assert_equal([six, four, five], one.scheduled_before)
      assert_equal([], two.scheduled_before)
      assert_equal([six, four, one, five], three.scheduled_before)
      assert_equal([six], four.scheduled_before)
      assert_equal([six, four, one], five.scheduled_before)
      assert_equal([], six.scheduled_before)
    end

    def test_scheduled_after
      one_week_from_now = 1.week.from_now

      one = create_release(name: '1', publish_at: one_week_from_now)
      two = create_release(name: '2', publish_at: nil)
      three = create_release(name: '3', publish_at: 8.days.from_now)
      four = create_release(name: '4', publish_at: 6.days.from_now)
      five = create_release(name: '5', publish_at: one_week_from_now)
      six = create_release(name: '6', publish_at: 4.days.from_now)

      assert_equal([five, three], one.scheduled_after)
      assert_equal([], two.scheduled_after)
      assert_equal([], three.scheduled_after)
      assert_equal([one, five, three], four.scheduled_after)
      assert_equal([one, three], five.scheduled_after)
      assert_equal([four, one, five, three], six.scheduled_after)
    end

    def test_previous
      release = create_release
      assert_nil(release.previous)

      release.update_attributes!(publish_at: 1.week.from_now)
      assert_nil(release.previous)

      first = create_release(publish_at: 1.day.from_now)
      assert_equal(first, release.previous)

      third = create_release(publish_at: 2.days.from_now)
      assert_equal(third, release.previous)
    end

    def test_build_undo
      release = create_release
      undo = release.build_undo
      assert(undo.name.present?)
      assert_equal(undo, release.undo)
      assert_equal(release, undo.undoes)
    end
  end
end
