module Workarea
  module Admin
    class CreateReleasesController < Admin::ApplicationController
      required_permissions :releases

      before_action :find_release

      def index
        render :setup
      end

      def create
        @release.attributes = params[:release]

        if @release.save
          flash[:success] =
            t('workarea.admin.create_releases.flash_messages.created')
          redirect_to plan_create_release_path(@release)
        else
          render :setup, status: :unprocessable_entity
        end
      end

      def edit
        render :setup
      end

      def plan
        self.current_release = @release

        search = Search::AdminReleasables.new(params)
        @search = SearchViewModel.new(
          search,
          view_model_options.merge(show_type: true)
        )
      end

      private

      def find_release
        model = if params[:id].present?
                  Release.find(params[:id])
                else
                  Release.new(params[:release])
                end

        @release = ReleaseViewModel.new(model, view_model_options)
      end
    end
  end
end
