module Workarea
  module Admin
    class BulkActionsController < Admin::ApplicationController
      def create
        klass = params[:type].constantize
        raise unless klass < BulkAction
        bulk_action = Mongoid::Factory.build(klass, bulk_action_params(klass))

        if !bulk_action.valid?
          flash[:error] = bulk_action.errors.full_messages.to_sentence
          redirect_back(fallback_location: return_to || root_path)
        elsif !bulk_action.count.positive?
          flash[:error] = I18n.t('workarea.admin.bulk_actions.empty_selection')
          redirect_back(fallback_location: return_to || root_path)
        else
          bulk_action.save!
          redirect_to url_for([
            :edit,
            bulk_action,
            { only_path: true, return_to: return_to }
          ])
        end
      end

      def selected
        @search = BulkActionSelections.new(params[:id], params)
        @results = @search.results.map { |r| wrap_in_view_model(r) }
      end

      def destroy
        BulkAction.find(params[:id]).destroy
        redirect_to return_to || root_path
      end

      private

      def bulk_action_params(klass)
        base = params.select { |k, v| k.in?(klass.fields.keys) }
        base.merge(params[:bulk_action] || {})
      end
    end
  end
end
