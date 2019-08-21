module Workarea
  module Admin
    class ReleaseViewModel < ApplicationViewModel
      include CommentableViewModel

      def timeline
        @timeline ||= TimelineViewModel.new(model)
      end

      def changesets_with_releasable
        @changesets_with_releasable ||= model
                          .changesets
                          .map { |c| ChangesetViewModel.wrap(c) }
                          .select { |changeset| changeset.root.present? }
                          .reject { |changeset| changeset.releasable.blank? }
      end

      def can_undo?
        !undone? && changesets.any? { |c| c.undo.present? }
      end

      def published_on_date?(date)
        date == publish_time.to_date
      end

      def ended_on_date?(date)
        return true if content_release?
        date == model.undo_at.to_date
      end

      def content_release?
        model.undo_at.blank?
      end

      def publish_time
        model.publish_at || model.published_at
      end

      def undo_time
        model.undo_at || model.undone_at
      end
    end
  end
end
