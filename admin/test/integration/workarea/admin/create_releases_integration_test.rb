require 'test_helper'

module Workarea
  module Admin
    class CreateReleasesIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_creates_releases
        post admin.create_releases_path, params: { release: { name: 'foo bar' } }
        assert_equal(1, Release.count)
        assert_equal('foo bar', Release.first.name)
      end

      def test_updates_releases
        release = create_release(name: 'new release')
        post admin.create_releases_path,
          params: { id: release.id, release: { name: 'foo bar' } }

        assert_equal(1, Release.count)
        assert_equal('foo bar', Release.first.name)
      end
    end
  end
end
