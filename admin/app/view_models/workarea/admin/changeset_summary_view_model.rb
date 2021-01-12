module Workarea
  module Admin
    class ChangesetSummaryViewModel < ApplicationViewModel
      delegate :model_name, to: :model_class

      def count
        model['count']
      end

      def type
        model['_id']
      end

      def type_filter
        search_model&.type || model_name.param_key
      end

      def label
        type_filter.titleize.pluralize(count)
      end

      def searchable?
        search_model.present?
      end

      private

      def model_class
        @model_class ||= type.constantize
      end

      def search_model
        return @search_model if defined?(@serch_model)

        @search_model = Search::Admin.for(model_class.new)
      end
    end
  end
end
