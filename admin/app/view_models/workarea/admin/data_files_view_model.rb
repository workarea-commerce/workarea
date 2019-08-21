module Workarea
  module Admin
    class DataFilesViewModel < ApplicationViewModel
      def type
        (options[:type] || 'Workarea::DataFile::Import').constantize
      end

      def imports?
        type == Workarea::DataFile::Import
      end

      def models
        @models ||= type.all.page(page).per(per_page).order(created_at: :desc)
      end

      def results
        @results ||= PagedArray.from(
          DataFileViewModel.wrap(models),
          page,
          per_page,
          models.total_count
        )
      end

      def ttl_in_words
        Workarea.config.data_file_operation_ttl.parts.map do |part|
          part.reverse.join(' ')
        end.join(', ')
      end

      private

      def per_page
        Workarea.config.per_page
      end

      def page
        options[:page] || 1
      end
    end
  end
end
