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
        Search::Admin.for(model_class.new).type
      end

      def label
        type_filter.titleize.pluralize(count)
      end

      private

      def model_class
        @model_class ||= type.constantize
      end
    end
  end
end
