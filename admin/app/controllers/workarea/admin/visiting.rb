module Workarea
  module Admin
    module Visiting
      extend ActiveSupport::Concern

      included do
        helper_method :most_visited
        after_action :save_visit
      end

      def most_visited
        @most_visited ||= User::AdminVisit.most_visited(current_user.id)
      end

      private

      def save_visit
        return unless save_visit?

        User::AdminVisit.create!(
          name: response_title,
          path: request.path,
          user_id: current_user.id
        )
      end

      def save_visit?
        !request.xhr? &&
          request.get? &&
          !response.redirect? &&
          !request.path.in?(excluded_paths) &&
          response_title.present?
      end

      def excluded_paths
        Workarea.config.admin_visit_excluded_paths.map do |path_method|
          send(path_method)
        end
      end

      def response_title
        @response_title ||= Nokogiri::XML(response.body)
                              .css('title')
                              .try(:text)
                              .to_s
                              .gsub(/\[#{Rails.env.upcase}\]/, '')
                              .strip
      end
    end
  end
end
