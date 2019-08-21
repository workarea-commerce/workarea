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

    def test_undone_within_includes_releases_within_a_specified_range
      create_release(publish_at: 1.month.from_now, undo_at: 2.months.from_now)
      release_2 = create_release(publish_at: 1.day.from_now, undo_at: 1.day.from_now)

      result = Release.undone_within(Time.current, 2.days.from_now)
      assert_equal([release_2], result)
    end

    def test_is_sorted_by_undone_undo_time
      release_3 = create_release(published_at: 1.hour.ago, undo_at: 1.hour.from_now)
      release_2 = create_release(published_at: 2.days.ago, undone_at: 1.day.ago)
      release_1 = create_release(published_at: 1.week.ago, undone_at: 2.days.ago)

      result = Release.undone_within(3.days.ago, 3.days.from_now)
      assert_equal([release_1, release_2, release_3], result)
    end

    def test_publish_sets_publish_at_to_nil
      release = create_release(
        publish_at: 1.week.from_now,
        undone_at: 1.week.ago
      )
      release.publish!
      release.reload
      assert(release.publish_at.blank?)
    end

    def test_publish_sets_undone_at_to_nil
      release = create_release(
        publish_at: 1.week.from_now,
        undone_at: 1.week.ago
      )
      release.publish!
      release.reload
      assert(release.undone_at.blank?)
    end

    def test_undo_sets_undo_at_to_nil_if_in_the_future
      release = create_release(undo_at: 1.week.from_now)
      release.undo!
      release.reload
      assert(release.undo_at.blank?)
    end

    def test_undo_sets_undone_at
      release = create_release
      release.undo!
      release.reload
      assert(release.undone_at.present?)
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

    def test_cannot_undo_without_scheduled_publish
      release = Release.new(name: 'Foo', undo_at: 2.hours.from_now)

      refute(release.valid?, 'Release is valid with no publish date')
      assert_includes(release.errors.full_messages.to_sentence, I18n.t('workarea.errors.messages.undo_unpublished_release'))

      release.publish_at = 1.hour.from_now

      assert(release.valid?)
      assert(release.save!)

      release.publish_at = nil
      release.published_at = 1.hour.ago

      assert(release.save!)

      release.published_at = nil

      refute(release.valid?)
      assert_includes(release.errors.full_messages.to_sentence, I18n.t('workarea.errors.messages.undo_unpublished_release'))
    end
  end

  class ReleaseJobsTest < TestCase
    setup :setup_sidekiq
    teardown :teardown_sidekiq

    def setup_sidekiq
      Sidekiq::Testing.disable!

      @scheduled_set = Sidekiq::ScheduledSet.new
      @scheduled_set.clear
    end

    def teardown_sidekiq
      Sidekiq::Testing.inline!
    end

    def test_save_updates_the_publish_job
      release = create_release
      release.publish_at = Time.current + 1.month

      release.save
      release.reload

      assert(release.publish_job_id.present?)
    end

    def test_save_does_not_save_the_publish_job_id_when_not_changing_publish_date
      release = create_release
      assert(release.publish_job_id.blank?)
      assert_equal(0, @scheduled_set.size)
    end

    def test_removing_publish_at_removes_job
      release = create_release(publish_at: 1.week.from_now)
      assert(release.publish_job_id.present?)
      assert_equal(1, @scheduled_set.size)

      release.update_attributes!(publish_at: nil)
      release.reload
      assert(release.publish_job_id.blank?)
      assert_equal(0, @scheduled_set.size)
    end

    def test_save_updates_the_undo_job
      release = create_release(publish_at: 2.weeks.from_now, undo_at: 1.month.from_now)

      assert(release.undo_job_id.present?)
    end

    def test_save_does_not_save_the_undo_job_id_when_not_changing_undo_date
      release = create_release
      release.save
      assert(release.undo_job_id.blank?)
      assert_equal(0, @scheduled_set.size)
    end

    def test_removing_undo_at_removes_job
      release = create_release(publish_at: 1.week.from_now, undo_at: 2.weeks.from_now)
      assert(release.undo_job_id.present?)
      assert_equal(2, @scheduled_set.size)

      release.update_attributes!(undo_at: nil)
      release.reload
      assert(release.undo_job_id.blank?)
      assert_equal(1, @scheduled_set.size)
    end

    def test_destroy_deletes_the_publish_job
      release = create_release(publish_job_id: '1234')
      release.destroy
      assert_equal(0, @scheduled_set.size)
    end

    def test_destroy_deletes_the_undo_job
      release = create_release(undo_job_id: '1234')
      release.destroy
      assert_equal(0, @scheduled_set.size)
    end
  end
end
