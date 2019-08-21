module Workarea
  class Release
    class Changes
      attr_reader :releasable

      def self.tracked_change?(key, old_value, new_value)
        !key.in?(Workarea.config.untracked_release_changes_fields) &&
          (old_value.present? || new_value.present?)
      end

      def initialize(releasable)
        @releasable = releasable
      end

      def to_h
        releasable.changes.keys.inject({}) do |memo, key|
          old_value, new_value = *releasable.changes[key]

          memo[key] = new_value if track_change?(key, old_value, new_value)
          memo
        end
      end

      def to_originals_h
        releasable.changes.keys.inject({}) do |memo, key|
          old_value, new_value = *releasable.changes[key]

          memo[key] = old_value if track_change?(key, old_value, new_value)
          memo
        end
      end

      def track_change?(key, old_value, new_value)
        self.class.tracked_change?(key, old_value, new_value) &&
          !change_appears_in_earlier_release?(key, new_value)
      end

      def change_appears_in_earlier_release?(key, new_value)
        Release.current.scheduled_before.flat_map(&:changesets).any? do |changeset|
          changeset.releasable == releasable && changeset.includes_change?(key, new_value)
        end
      end
    end
  end
end
