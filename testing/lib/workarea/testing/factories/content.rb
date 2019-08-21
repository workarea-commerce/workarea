module Workarea
  module Factories
    module Content
      Factories.add(self)

      def create_asset(overrides = {})
        attributes = factory_defaults(:asset).merge(overrides)
        Workarea::Content::Asset.create!(attributes)
      end

      def create_content(overrides = {})
        attributes = factory_defaults(:content).merge(overrides)
        Workarea::Content.create!(attributes)
      end

      def create_page(overrides = {})
        attributes = factory_defaults(:page).merge(overrides)
        Workarea::Content::Page.create!(attributes)
      end

      def pdf_file_path
        Factories::Content.pdf_file_path
      end

      def pdf_file
        Factories::Content.pdf_file
      end

      def self.pdf_file_path
        Testing::Engine.root.join('lib', 'workarea', 'testing', 'example_document.pdf')
      end

      def self.pdf_file
        IO.read(pdf_file_path)
      end
    end
  end
end
