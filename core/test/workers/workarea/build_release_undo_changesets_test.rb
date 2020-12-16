require 'test_helper'

module Workarea
  class BuildReleaseUndoChangesetsTest < TestCase
    def test_perform
      releasable_one = create_page(name: 'Foo')
      releasable_two = create_page(name: 'Bar')
      release = create_release

      release.as_current do
        releasable_one.update!(name: 'Changed Foo')
        releasable_two.update!(name: 'Changed Bar')
      end

      undo_release = release.build_undo.tap(&:save!)
      release.changesets.first.build_undo(release: undo_release).save!

      BuildReleaseUndoChangesets.new.perform(undo_release.id, release.id)

      undo_release.reload
      assert_equal(2, undo_release.changesets.count)
      assert_includes(undo_release.changesets.map(&:releasable), releasable_one)
      assert_includes(undo_release.changesets.map(&:releasable), releasable_two)
    end
  end
end
