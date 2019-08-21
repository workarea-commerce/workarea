module Workarea
  module Admin
    class ReleaseEventViewModel < ApplicationViewModel
      include Workarea::Admin::Engine.routes.url_helpers

      def all_day_event?
        return false unless starts_and_ends?
        ends_at - starts_at > 1
      end

      def starts_and_ends?
        starts_at.present? && ends_at.present?
      end

      def description
        description = [
          I18n.t('workarea.admin.releases.feed.view_release',
            url: release_url(host: Workarea.config.host, id: id))
        ]

        if all_day_event?
          description << I18n.t('workarea.admin.releases.feed.starts_on',
            date: starts_at.strftime('%b %-d, %Y at %r'))
          description << I18n.t('workarea.admin.releases.feed.ends_on',
            date: ends_at.strftime('%b %-d, %Y at %r'))
        end

        unless ends_at.present?
          description << I18n.t('workarea.admin.releases.feed.no_undo_date')
        end

        description.join('\n')
      end

      def publish_time
        model.publish_at || model.published_at
      end

      def undo_time
        model.undo_at || model.undone_at
      end

      def starts_at
        return if publish_time.nil?
        time = publish_time.strftime('%Y %m %d %H %M %S').split(' ').map(&:to_i)
        DateTime.civil(*time, publish_time.strftime('%z'))
      end

      def ends_at
        return if undo_time.nil?
        time = undo_time.strftime('%Y %m %d %H %M %S').split(' ').map(&:to_i)
        DateTime.civil(*time, undo_time.strftime('%z'))
      end
    end
  end
end
