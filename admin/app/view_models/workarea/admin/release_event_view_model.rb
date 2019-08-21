module Workarea
  module Admin
    class ReleaseEventViewModel < ApplicationViewModel
      include Workarea::Admin::Engine.routes.url_helpers

      def description
        I18n.t(
          'workarea.admin.releases.feed.view_release',
          url: release_url(host: Workarea.config.host, id: id)
        )
     end

      def starts_at
        model.publish_at || model.published_at
      end

      def ends_at
        return if starts_at.blank?
        starts_at + Workarea.config.release_publish_calendar_event_size
      end
    end
  end
end
