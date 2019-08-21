module Workarea
  module Admin
    class ChangesetsController < Admin::ApplicationController
      required_permissions :releases

      skip_around_action :set_release
      before_action :find_release

      def index
      end

      def destroy
        changeset = Release::Changeset.find(params[:id])
        changeset.destroy
        flash[:success] = t('workarea.admin.changesets.flash_messages.removed')
        redirect_back fallback_location: release_changesets_path(@release)
      end

      private

      def find_release
        Release.current = nil # we're showing changes so don't allow a current release
        model = Release.find(params[:release_id])
        @release = ReleaseViewModel.wrap(model, params)
      end
    end
  end
end
