module Workarea
  module Admin
    class DataFileImportsController < Admin::ApplicationController
      before_action :set_import

      def new
      end

      def sample
        filename = "#{@import.name.downcase.underscore}.#{@import.file_type}"
        send_data @import.sample_file_content, filename: filename, type: @import.file_type
      end

      def create
        if @import.save
          flash[:success] = t('workarea.admin.data_file_imports.flash_messages.processing')
          redirect_to return_to.presence || root_path
        else
          render :new, status: :unprocessable_entity
        end
      end

      private

      def set_import
        @import = DataFile::Import.new(import_params)
      end

      def import_params
        base = params.select { |k, v| k.in?(DataFile::Import.fields.keys) }
        base.merge(params[:import] || {}).merge(created_by_id: current_user.id)
      end
    end
  end
end
