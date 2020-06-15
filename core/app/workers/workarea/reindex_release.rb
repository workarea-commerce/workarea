module Workarea
  class ReindexRelease
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker

    sidekiq_options(
      enqueue_on: {
        Release => :save,
        only_if: -> { publish_at_changed? },
        with: -> { [id, publish_at_was, publish_at] }
      },
      queue: 'releases'
    )

    def perform(id, previous_publish_at, new_publish_at)
      rescheduled_release = Release.find(id)
      earlier, later = if previous_publish_at.present? && new_publish_at.present?
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
