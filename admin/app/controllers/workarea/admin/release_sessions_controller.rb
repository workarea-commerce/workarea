module Workarea
  module Admin
    class ReleaseSessionsController < Admin::ApplicationController

      def create
        release = Release.find(params[:release_id]) rescue nil
        self.current_release = release

        if request.xhr?
          render json: { release: release }
        elsif params[:return_to].present?
          redirect_to URI.parse(params[:return_to]).request_uri
        elsif params[:release_id].present?
          redirect_back fallback_location: url_for(release)
        else
          redirect_back fallback_location: releases_path
        end
      end

      def touch
        current_release_session.touch
      end
    end
  end
end
