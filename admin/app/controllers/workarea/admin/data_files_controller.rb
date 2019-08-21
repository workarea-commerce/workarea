module Workarea
  module Admin
    class DataFilesController < Admin::ApplicationController
      def index
        @data_files = DataFilesViewModel.new(nil, view_model_options)
      end

      def errors
        @data_file = DataFileViewModel.wrap(GlobalID.find(params[:id]))
      end
    end
  end
end
