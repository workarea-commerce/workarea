module Workarea
  module Admin
    class ReleasesController < Admin::ApplicationController
      include StorefrontHelper

      required_permissions :releases

      before_action :find_release, except: :changes
      before_action :find_calendar, only: [:calendar, :update]
      before_action :authenticate_user_by_token, only: :calendar_feed
      skip_before_action :require_login, :require_admin, only: :calendar_feed
      around_action :set_time_zone, only: :calendar

      def index
        search = Search::AdminReleases.new(params)
        @search = Admin::ReleaseSearchViewModel.new(search, view_model_options)
      end

      def show
      end

      def edit
      end

      def create
        @release.attributes = params[:release]
        @release.save
        render json: { release: @release.model }
      end

      def calendar
      end

      def new
      end

      def update
        if @release.update_attributes(params[:release])
          flash[:success] = t('workarea.admin.releases.flash_messages.saved')
          redirect_to release_path(@release)
        else
          flash[:error] = t('workarea.admin.releases.flash_messages.saved_error')
          render :edit
        end
      end

      def publish
        self.current_release = nil
        PublishRelease.perform_async(@release.id)

        flash[:success] = t('workarea.admin.releases.flash_messages.published')
        redirect_to return_to || release_path(@release)
      end

      def undo
        self.current_release = nil
        @release.undo!

        flash[:success] = t('workarea.admin.releases.flash_messages.reverted')
        redirect_to return_to || release_path(@release)
      end

      def destroy
        self.current_release = nil
        @release.destroy

        flash[:success] = t('workarea.admin.releases.flash_messages.removed')
        redirect_to releases_path
      end

      def calendar_feed
        send_data ReleasesFeedViewModel.wrap(nil).to_ical,
                  filename: params[:filename],
                  type: 'text/calendar'
      end

      private

      def set_time_zone
        old_time_zone = Time.zone
        time_offset = params[:time_offset].to_i / 100
        Time.zone = time_offset.hours unless params[:time_offset].blank?
        yield
      ensure
        Time.zone = old_time_zone
      end

      def find_release
        model = if params[:id].present?
                  Release.find(params[:id])
                else
                  Release.new(params[:release])
                end

        @release = ReleaseViewModel.new(model, view_model_options)
      end

      def find_calendar
        @calendar = ReleaseCalendarViewModel.new(@release, view_model_options)
      end

      def authenticate_user_by_token
        unless User.find_by_token(params[:token]).try(:releases_access?)
          head :unauthorized
          return false
        end
      end
    end
  end
end
