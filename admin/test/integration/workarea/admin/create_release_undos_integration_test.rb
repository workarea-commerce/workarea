require 'test_helper'

module Workarea
  module Admin
    class CreateReleaseUndosIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_create
        releasable = create_page(name: 'Foo')
        release = create_release

        release.as_current { releasable.update_attributes!(name: 'Bar') }
        release.changesets.create!(releasable: Catalog::Product.new) # test missing releasable

        post admin.release_undos_path(release),
          params: { release: { name: 'Undo Bar', tag_list: 'foo,bar,baz' } }

        assert_equal(2, Release.count)
        undo_release = Release.desc(:created_at).first

        assert_equal(undo_release, release.reload.undos.first)
        assert_equal('Undo Bar', undo_release.name)
        assert_equal(%w(foo bar baz), undo_release.tags)
        assert_equal(1, undo_release.changesets.size)
        assert_equal(1, undo_release.changesets.first.changeset.size)
        assert_equal(releasable, undo_release.changesets.first.releasable)
        assert_equal([releasable], Search::AdminSearch.new(upcoming_changes: [undo_release.id]).results)
      end

      def test_create_for_large_changesets
        Sidekiq::Testing.fake!

        Workarea.config.per_page = 1

        releasable_one = create_page(name: 'Foo')
        releasable_two = create_page(name: 'Bar')
        release = create_release

        release.as_current do
          releasable_one.update!(name: 'Changed Foo')
          releasable_two.update!(name: 'Changed Bar')
        end

        post admin.release_undos_path(release),
          params: { release: { name: 'Undo Test' } }

        assert_equal(2, Release.count)
        undo_release = Release.desc(:created_at).first
        assert_equal(1, undo_release.changesets.size)
        assert_equal(1, BuildReleaseUndoChangesets.jobs.size)
      end
    end
  end
end
