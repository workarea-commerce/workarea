require 'test_helper'

module Workarea
  module Admin
    class ReleasesIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      setup :save_timezone
      teardown :reset_timezone

      def save_timezone
        @time_zone = Time.zone
        Time.zone = ActiveSupport::TimeZone['UTC']
      end

      def reset_timezone
        Time.zone = @time_zone
      end

      def test_creates_releases
        post admin.releases_path, params: { release: { name: 'foo bar' } }
        assert_equal(1, Release.count)
        assert_equal('foo bar', Release.first.name)
      end

      def test_updates_releases
        release = create_release(name: 'new release')
        patch admin.release_path(release),
          params: { release: { name: 'foo bar' } }

        assert_equal(1, Release.count)
        assert_equal('foo bar', Release.first.name)
      end

      def test_publishes_content
        release = create_release(name: 'new release')

        patch admin.publish_release_path(release)

        release.reload
        assert(release.published?)
      end

      def test_deletes_releaeses
        delete admin.release_path(create_release)
        assert_equal(0, Release.count)
      end

      def test_calendar_feed
        user = create_user(admin: true)
        create_release(
          name: 'foobar',
          publish_at: 1.week.from_now,
          undo_at: 1.month.from_now
        )

        get admin.calendar_feed_releases_path(token: user.token)
        assert_response :unauthorized

        patch admin.user_path(user), params: { user: { releases_access: true } }

        user.reload
        get admin.calendar_feed_releases_path(token: user.token)
        assert_response :ok

        old_token = user.token

        user.update_attributes!(admin: false)
        user.update_attributes!(admin: true, releases_access: true)

        get admin.calendar_feed_releases_path(token: old_token)
        assert_response :unauthorized

        user.reload
        get admin.calendar_feed_releases_path(token: user.token)
        assert_response :ok

        assert_equal(1, response.body.scan(/BEGIN:VEVENT/).length)

        set_current_user(nil)
        get admin.calendar_feed_releases_path(token: user.token)
        assert_response :ok

        super_user = create_user(super_admin: true)
        get admin.calendar_feed_releases_path(token: super_user.token)
        assert_response :ok
      end

      def test_calendar_feed_timezones
        user = create_user(admin: true, releases_access: true)

        Time.zone = ActiveSupport::TimeZone['Pacific/Midway'] # UTC-11

        publish_at = 1.week.from_now
        create_release(name: 'foobar', publish_at: publish_at)

        get admin.calendar_feed_releases_path(token: user.token)

        assert_includes(response.body, 'BEGIN:VTIMEZONE')
        assert_includes(response.body, 'TZID:Pacific/Midway')
        assert_includes(response.body, 'TZOFFSETTO:-1100')
        assert_includes(response.body, "X-WR-CALNAME:#{t('workarea.admin.releases.feed.name', site_name: Workarea.config.site_name)}")
      end

      def test_single_day_events
        user = create_user(admin: true, releases_access: true)

        publish_at = 1.hour.from_now
        undo_at = 2.hours.from_now
        create_release(
          name: 'Single-Day',
          publish_at: publish_at,
          undo_at: undo_at
        )

        get admin.calendar_feed_releases_path(token: user.token)

        assert_includes(response.body, "DTSTART;TZID=Etc/UTC:#{publish_at.strftime('%Y%m%dT%H%M%S')}\r\n")
        assert_includes(response.body, "DTEND;TZID=Etc/UTC:#{undo_at.strftime('%Y%m%dT%H%M%S')}\r\n")
      end

      def test_overnight
        user = create_user(admin: true, releases_access: true)

        publish_at = 1.hour.from_now
        undo_at = 24.hours.from_now
        create_release(
          name: 'Single-Day',
          publish_at: publish_at,
          undo_at: undo_at
        )

        get admin.calendar_feed_releases_path(token: user.token)

        assert_includes(response.body, "DTSTART;TZID=Etc/UTC:#{publish_at.strftime('%Y%m%dT%H%M%S')}\r\n")
        assert_includes(response.body, "DTEND;TZID=Etc/UTC:#{undo_at.strftime('%Y%m%dT%H%M%S')}\r\n")
      end

      def test_multi_day_events
        user = create_user(admin: true, releases_access: true)

        publish_at = 1.week.from_now
        undo_at = 2.weeks.from_now
        create_release(
          name: 'Multi-Day',
          publish_at: publish_at,
          undo_at: undo_at
        )

        get admin.calendar_feed_releases_path(token: user.token)

        assert_includes(response.body, "DTSTART;TZID=Etc/UTC;VALUE=DATE:#{publish_at.strftime('%Y%m%d')}\r\n")
        assert_includes(response.body, "DTEND;TZID=Etc/UTC;VALUE=DATE:#{undo_at.strftime('%Y%m%d')}\r\n")
      end

      def test_release_without_undo
        user = create_user(admin: true, releases_access: true)

        publish_at = 1.hour.from_now
        create_release(
          name: 'No Undo',
          publish_at: publish_at
        )

        get admin.calendar_feed_releases_path(token: user.token)

        assert_includes(response.body, "DTSTART;TZID=Etc/UTC:#{publish_at.strftime('%Y%m%dT%H%M%S')}\r\n")
        assert_includes(response.body, t('workarea.admin.releases.feed.no_undo_date'))
      end
    end
  end
end
