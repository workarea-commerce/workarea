module Workarea
  module Admin
    class CreateReleaseUndosController < Admin::ApplicationController
      required_permissions :releases

      before_action :find_release
      before_action :find_undo_release

      def new
      end

      def create
        @undo_release.attributes = params[:release]

        if @undo_release.save
          @release.changesets.limit(Workarea.config.per_page).each do |changeset|
            if changeset.releasable.present?
              changeset.build_undo(release: @undo_release.model).save!
              changeset.releasable.run_callbacks(:save)
            end
          end

          BuildReleaseUndoChangesets.perform_async(
            @undo_release.id,
            @release.id
          ) if @release.changeset_count > Workarea.config.per_page

          flash[:success] = t('workarea.admin.create_release_undos.flash_messages.saved')
          redirect_to review_release_undo_path(@release, @undo_release)
        else
          render :new, status: :unprocessable_entity
        end
      end

      def review
      end

      private

      def find_release
        model = Release.find(params[:release_id])
        @release = ReleaseViewModel.new(model, view_model_options)
      end

      def find_undo_release
        model =
          if params[:id].present?
            @release.model.undos.find(params[:id])
          else
            @release.build_undo
          end

        @undo_release = ReleaseViewModel.wrap(model, view_model_options)
      end
    end
  end
end
