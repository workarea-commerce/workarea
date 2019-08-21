module Workarea
  module Admin
    class DataFileExportsController < Admin::ApplicationController
      before_action :set_export, except: :show

      def show
        export = DataFile::Export.find(params[:id])
        send_file export.file.file, filename: export.file_name
      end

      def new
      end

      def create
        if @export.save
          flash[:success] = t('workarea.admin.data_file_exports.flash_messages.processing')
          redirect_to return_to.presence || root_path
        else
          render :new, status: :unprocessable_entity
        end
      end

      private

      def set_export
        @export = DataFile::Export.new(export_params)
      end

      def export_params
        base = params.select { |k, v| k.in?(DataFile::Export.fields.keys) }
        base.merge(params[:export] || {}).merge(created_by_id: current_user.id)
      end
    end
  end
end
