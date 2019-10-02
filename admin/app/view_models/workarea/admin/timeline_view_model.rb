module Workarea
  module Admin
    class TimelineViewModel < ApplicationViewModel
      def upcoming_changesets
        @upcoming_changesets ||= ChangesetViewModel.wrap(
          (model_changesets + content_changesets)
            .sort { |c| c.release.publish_at }
            .reverse
        )
      end

      def unscheduled_changesets
        @unscheduled_changesets ||= ChangesetViewModel.wrap(
          unscheduled_model_changesets + unscheduled_content_changesets
        )
      end

      def activity
        @activity ||= ActivityViewModel.new(nil, id: model.id)
      end

      def activity_by_day
        @days ||= activity.entries.reduce({}) do |memo, entry|
          day = entry.created_at.to_date
          memo[day] ||= []
          memo[day] << entry
          memo
        end
      end

      def today_has_activity
        activity_by_day[Time.zone.today].present?
      end

      def empty?
        upcoming_changesets.empty? && activity.entries.empty?
      end

      def subject
        @subject ||= ApplicationController.wrap_in_view_model(model, options)
      end

      private

      def model_changesets
        Release::Changeset
          .by_document_path(model)
          .any_in(release_id: upcoming_releases.map(&:id))
      end

      def unscheduled_model_changesets
        Release::Changeset
          .by_document_path(model)
          .any_in(release_id: unscheduled_releases.map(&:id))
      end

      def content_changesets
        return [] unless model.is_a?(Contentable)

        Workarea::Content.for(model)
          .changesets
          .any_in(release_id: upcoming_releases.map(&:id))
          .to_a
      end

      def unscheduled_content_changesets
        return [] unless model.is_a?(Contentable)

        Workarea::Content.for(model)
          .changesets
          .any_in(release_id: unscheduled_releases.map(&:id))
          .to_a
      end

      def upcoming_releases
        @upcoming_releases ||= (Release.upcoming - unscheduled_releases).to_a
      end

      def unscheduled_releases
        @unscheduled_releases ||= Release.unscheduled.to_a
      end
    end
  end
end
