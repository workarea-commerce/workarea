module Workarea
  module DataFile
    class TaxImport < Import
      field :tax_category_id, type: String
      index(_type: 1)

      validates :tax_category_id, presence: true
      before_process :clear_existing

      def model_class
        Workarea::Tax::Category
      end

      def model_type
        Workarea::Tax::Rate.name
      end

      def file_type
        'tax_rates'
      end

      private

      def assert_valid_file_type
        CSV.read(file.path)
      end

      def clear_existing
        Workarea::Tax::Rate.where(category_id: tax_category_id).destroy_all
      end
    end
  end
end
