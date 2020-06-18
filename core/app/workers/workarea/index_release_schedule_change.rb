module Workarea
  class IndexReleaseScheduleChange
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker

    sidekiq_options(
      enqueue_on: {
        Release => [:save, :destroy],
        only_if: -> { publish_at_changed? || destroyed? },
        with: -> { [id, publish_at_was, publish_at] }
      },
      queue: 'releases'
    )

    def perform(id, previous_publish_at, new_publish_at)
      # When destroyed, changesets for the release ID will still exist and be used to update the index
      rescheduled_release = Release.find_or_initialize_by(id: id)

      earlier, later = if rescheduled_release.persisted? && previous_publish_at.present? && new_publish_at.present?
        [previous_publish_at, new_publish_at].sort
      elsif previous_publish_at.present?
        [previous_publish_at, nil]
      else
        [new_publish_at, nil]
      end

      IndexReleaseSchedulePreviews
        .new(release: rescheduled_release, starts_at: earlier, ends_at: later)
        .perform
    end
  end
end
