module Workarea
  class BuildReleaseUndoChangesets
    include Sidekiq::Worker

    def perform(undo_release_id, release_id)
      release = Release.find(release_id)
      undo_release = Release.find(undo_release_id)

      existing_changesets = undo_release.changesets.to_a
      matching_changeset = ->(changeset, existing_changesets) do
        existing_changesets.any? do |cs|
          changeset.releasable_type == cs.releasable_type &&
          changeset.releasable_id == cs.releasable_id
        end
      end

      release.changesets.each_by(500) do |changeset|
        next if matching_changeset.call(changeset, existing_changesets)
        changeset.build_undo(release: undo_release).save!
      end
    end
  end
end
