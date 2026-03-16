# frozen_string_literal: true

module Workarea
  module Admin
    class BulkActionsController < Admin::ApplicationController
      def create
        klass = bulk_action_class_for(params[:type])

        if klass.nil?
          head :unprocessable_entity
          return
        end

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

      # Returns the BulkAction subclass whose name matches +type_name+, or nil
      # if the name is not present in Workarea.config.bulk_action_types.
      # Constantize is called on the allowlisted config strings, never on the
      # raw parameter value.
      def bulk_action_class_for(type_name)
        target = type_name.to_s
        Workarea.config.bulk_action_types.lazy
          .map { |t| t.constantize }
          .find { |klass| klass.name == target }
      end

      def bulk_action_params(klass)
        base = params.select { |k, v| k.in?(klass.fields.keys) }
        base.merge(params[:bulk_action] || {})
      end
    end
  end
end
