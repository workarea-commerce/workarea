module Workarea
  module Admin
    class DataFileTaxImportsController < Admin::ApplicationController
      required_permissions :settings
      before_action :find_tax_category

      def new
        @import = DataFile::TaxImport.new
      end

      def create
        @import = DataFile::TaxImport.new(import_params)

        if @import.save
          flash[:success] = t('workarea.admin.data_file_tax_imports.flash_messages.processing')
          redirect_to tax_category_path(@tax_category)
        else
          render :new, status: :unprocessable_entity
        end
      end

      private

      def find_tax_category
        @tax_category =
          if params[:tax_category_id].present?
            Tax::Category.find(params[:tax_category_id])
          elsif import_params[:tax_category_id].present?
            Tax::Category.find(import_params[:tax_category_id])
          end
      end

      def import_params
        params.fetch(:import, {}).merge(created_by_id: current_user.id)
      end
    end
  end
end
