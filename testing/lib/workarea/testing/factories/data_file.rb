module Workarea
  module Factories
    module DataFile
      Factories.add(self)

      def create_import(overrides = {})
        attributes = factory_defaults(:import).merge(overrides)
        Workarea::DataFile::Import.create!(attributes)
      end

      def create_export(overrides = {})
        attributes = factory_defaults(:export).merge(overrides)
        Workarea::DataFile::Export.create!(attributes)
      end

      def tax_rates_csv_path
        "#{Core::Engine.root}/test/fixtures/tax_rates.csv"
      end
    end
  end
end
