require 'test_helper'

module Workarea
  module Admin
    class ChangesetsIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_deletes_a_changeset
        page = create_page(name: 'Foo')
        release = create_release
        release.as_current do
          page.update_attributes!(name: 'Bar')
        end

        changeset = release.changesets.first

        delete admin.release_changeset_path(release, changeset)
        assert_equal(0, Release::Changeset.count)
      end
    end
  end
end
