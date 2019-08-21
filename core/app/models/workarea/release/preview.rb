module Workarea
  class Release
    class Preview
      attr_reader :release

      def initialize(release)
        @release = release
      end

      def releases
        @releases ||= release.scheduled_before + [release]
      end

      def changesets
        @changesets ||= releases.flat_map(&:changesets)
      end

      def changesets_for(model)
        changesets.select do |changeset|
          # Check this way because loading the releasable will cause `load_release_changes`
          # to run this, resulting in a stack overflow.
          changeset.releasable_type == model.class.name &&
            changeset.releasable_id.to_s == model.id.to_s
        end
      end
    end
  end
end
