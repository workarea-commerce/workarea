require 'test_helper'

module Workarea
  module Admin
    class ReleasesIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

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
        create_release(name: 'foobar', publish_at: 1.week.from_now)

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

      def test_single_release
        current_time_zone = Time.zone
        Time.zone = ActiveSupport::TimeZone['UTC']

        user = create_user(admin: true, releases_access: true)
        release = create_release(publish_at: 1.hour.from_now)

        get admin.calendar_feed_releases_path(token: user.token)

        assert_includes(response.body, "DTSTART;TZID=Etc/UTC:#{release.publish_at.strftime('%Y%m%dT%H%M%S')}\r\n")
        assert_match(/DTEND;TZID=Etc\/UTC:\d{8}T\d{6}/, response.body)

      ensure
        Time.zone = current_time_zone
      end

      def test_saving_release_during_time_based_previewing
        first = create_release(publish_at: 1.day.from_now)
        second = create_release(publish_at: 2.days.from_now)

        product = create_product(name: 'Foo', description: 'One')
        first.as_current { product.update_attributes!(name: 'Bar', description: 'Two') }
        second.as_current { product.update_attributes!(name: 'Baz') }

        post admin.release_session_path, params: { release_id: second.id }
        patch admin.catalog_product_path(product), params: { product: { name: 'Qux' } }

        second.reload
        assert_equal(1, second.changesets.size)
        assert_equal(1, second.changesets.first.changeset.size)
        assert_equal(['name'], second.changesets.first.changeset.keys)
        assert_equal('Qux', second.changesets.first.changeset['name'][I18n.locale.to_s])

        third = create_release(publish_at: 3.days.from_now)
        post admin.release_session_path, params: { release_id: third.id }
        patch admin.catalog_product_path(product),
          params: { product: { name: 'Qoo', description: 'Two' } }

        third.reload
        assert_equal(1, third.changesets.size)
        assert_equal(1, third.changesets.first.changeset.size)
        assert_equal(['name'], third.changesets.first.changeset.keys)
        assert_equal('Qoo', third.changesets.first.changeset['name'][I18n.locale.to_s])

        patch admin.catalog_product_path(product),
          params: { product: { name: 'Quo', description: 'Three' } }

        third.reload
        assert_equal(1, third.changesets.size)
        assert_equal(2, third.changesets.first.changeset.size)
        assert_includes(third.changesets.first.changeset.keys, 'name')
        assert_includes(third.changesets.first.changeset.keys, 'description')
        assert_equal('Quo', third.changesets.first.changeset['name'][I18n.locale.to_s])
        assert_equal('Three', third.changesets.first.changeset['description'][I18n.locale.to_s])
      end

      def test_working_on_releases_that_publish_at_the_same_time
        publish_at = 1.week.from_now
        first = create_release(publish_at: publish_at)
        second = create_release(publish_at: publish_at)

        product = create_product(name: 'Foo', description: 'One')
        first.as_current { product.update_attributes!(name: 'Bar', description: 'Two') }
        second.as_current { product.update_attributes!(name: 'Baz') }

        post admin.release_session_path, params: { release_id: second.id }
        patch admin.catalog_product_path(product), params: { product: { name: 'Qux' } }

        first.reload
        assert_equal(1, first.changesets.size)
        assert_equal(2, first.changesets.first.changeset.size)
        assert_equal(%w(name description), first.changesets.first.changeset.keys)
        assert_equal('Bar', first.changesets.first.changeset['name'][I18n.locale.to_s])
        assert_equal('Two', first.changesets.first.changeset['description'][I18n.locale.to_s])

        second.reload
        assert_equal(1, second.changesets.size)
        assert_equal(1, second.changesets.first.changeset.size)
        assert_equal(['name'], second.changesets.first.changeset.keys)
        assert_equal('Qux', second.changesets.first.changeset['name'][I18n.locale.to_s])
      end
    end
  end
end
