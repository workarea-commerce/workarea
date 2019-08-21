module Workarea
  module Admin
    class BulkActionSequentialProductEditViewModel < ApplicationViewModel
      def first?
        index.zero?
      end

      def last?
        index == model.count - 1
      end

      def next
        index + 1
      end

      def previous
        index - 1
      end

      def index
        options[:index].to_i
      end
    end
  end
end
