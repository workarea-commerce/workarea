require 'test_helper'

module Workarea
  class UndoReleaseTest < TestCase
    def test_undoes_the_release
      release = create_release
      release.publish!
      UndoRelease.new.perform(release.id)
      release.reload
      assert(release.undone?)
    end

    def test_tracks_the_changes_in_the_audit_log
      release = create_release
      release.publish!

      UndoRelease.new.perform(release.id)

      assert_equal(1, Mongoid::AuditLog::Entry.count)
      assert(Mongoid::AuditLog::Entry.first.modifier.system?)
    end
  end
end
