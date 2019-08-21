module Workarea
  module Admin
    class ChangesetViewModel < ApplicationViewModel
      def releasable
        @releasable ||= Mongoid::DocumentPath.find(model.document_path)
      end

      def name
        [root, releasable]
          .reject(&:blank?)
          .uniq
          .map(&:name)
          .reject(&:blank?)
          .join(' - ')
      end

      def root
        @root ||= Mongoid::DocumentPath.find(model.document_path.take(1))
      end

      def localized_change?(field, value)
        field = field.to_s

        !!releasable.class.fields[field] &&
          !!releasable.class.fields[field].options[:localize] &&
          value.is_a?(Hash)
      end

      def currency_change?(field, value)
        field = field.to_s

        !!releasable.class.fields[field] &&
          releasable.class.fields[field].options[:type] == Money &&
          value.is_a?(Hash)
      end

      def new_value_for(field)
        get_localized_value(field, changeset[field])
      end

      def old_value_for(field)
        return get_localized_value(field, undo[field]) if undo.present?
        current_releasable.send(field)
      end

      def release_date
        if release.scheduled?
          release.publish_at
        elsif release.published?
          release.published_at
        end
      end

      def publish_humanized
        if release.published?
          t('workarea.admin.changesets.published_on')
        elsif release.scheduled?
          t('workarea.admin.changesets.publishes_on')
        else
          t('workarea.admin.changesets.unscheduled')
        end
      end

      private

      def get_localized_value(field, value)
        if localized_change?(field, value)
          value.with_indifferent_access[I18n.locale]
        elsif currency_change?(field, value)
          Money.new(*value.values)
        else
          value
        end
      end

      def current_releasable
        @current_releasable ||= Release.with_current(nil) { releasable.reload }
      end
    end
  end
end
