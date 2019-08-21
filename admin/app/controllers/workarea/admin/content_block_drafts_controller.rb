module Workarea
  module Admin
    class ContentBlockDraftsController < Admin::ApplicationController
      def create
        unless params[:block][:hidden_breakpoints].present?
          params[:block][:hidden_breakpoints] = []
        end

        result = Content::BlockDraft.create!(params[:block])
        render json: { id: result.to_param }
      end
    end
  end
end
