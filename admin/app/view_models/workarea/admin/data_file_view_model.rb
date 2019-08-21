module Workarea
  module Admin
    class DataFileViewModel < ApplicationViewModel
      def type
        if model.class == DataFile::Import
          :import
        elsif model.class == DataFile::Export
          :export
        end
      end

      def created_by
        return @created_by if defined?(@created_by)
        @created_by = User.find(created_by_id) rescue nil
      end

      def error_count
        return 0 unless model.respond_to?(:file_errors)
        file_errors.values.flat_map(&:values).count +
          (error_message.present? ? 1 : 0)
      end

      def errors_with_line_numbers?
        file_type == 'csv'
      end
    end
  end
end
