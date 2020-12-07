module Workarea
  module Admin
    class ReleaseViewModel < ApplicationViewModel
      include CommentableViewModel

      def timeline
        @timeline ||= TimelineViewModel.new(model)
      end

      def changeset_count
        @changeset_count ||= model.changesets.count
      end

      def show_changeset_summary?
        changeset_count > Workarea.config.per_page
      end

      def changeset_summary
        @changeset_summary ||=
          Release::Changeset.summary(model.id).map do |type|
            ChangesetSummaryViewModel.new(type)
          end
      end

      def changesets_with_releasable
        @changesets_with_releasable ||= model
                          .changesets
                          .latest
                          .map { |c| ChangesetViewModel.wrap(c) }
                          .select { |changeset| changeset.root.present? }
                          .reject { |changeset| changeset.releasable.blank? }
      end

      def calendar_at
        model.publish_at || model.published_at
      end

      def calendar_on
        calendar_at&.to_date
      end

      def undo
        return unless undo?
        @undo ||= ReleaseViewModel.wrap(model.undo, options)
      end

      def undoes
        return unless undoes?
        @undoes ||= ReleaseViewModel.wrap(model.undoes, options)
      end
    end
  end
end
