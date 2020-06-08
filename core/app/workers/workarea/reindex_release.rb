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
      queue: 'high'
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

      affected_releases = Release.scheduled(after: earlier, before: later).includes(:changesets).to_a
      affected_releases += [rescheduled_release]
      affected_releases.uniq!

      affected_models = affected_releases.flat_map(&:changesets).flat_map(&:releasable)

      affected_releases.each do |release|
        affected_models.each do |releasable|
          Search::Storefront.new(releasable.in_release(release)).destroy

          # Different models have different indexing workers, running callbacks
          # ensures the appropriate worker is triggered
          releasable.run_callbacks(:save_release_changes)
        end
      end
    end
  end
end
