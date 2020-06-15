module Workarea
  class IndexReleaseSchedulePreviews
    attr_reader :release, :starts_at, :ends_at

    def initialize(release: nil, starts_at: nil, ends_at: nil)
      @release = release
      @starts_at = starts_at
      @ends_at = ends_at
    end

    def affected_releases
      result = Release
        .scheduled(after: starts_at, before: ends_at)
        .includes(:changesets)
        .to_a

      result << release if release.present?
      result.uniq
    end

    def affected_models
      affected_releases.flat_map(&:changesets).flat_map(&:releasable).compact
    end

    def perform
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
