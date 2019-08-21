module Workarea
  module Factories
    module Navigation
      Factories.add(self)

      def create_taxon(overrides = {})
        attributes = factory_defaults(:taxon).merge(overrides)
        Workarea::Navigation::Taxon.create!(attributes)
      end

      def create_redirect(overrides = {})
        attributes = factory_defaults(:redirect).merge(overrides)
        Workarea::Navigation::Redirect.create!(attributes)
      end

      def create_menu(overrides = {})
        attributes = factory_defaults(:menu).merge(overrides)
        Workarea::Navigation::Menu.create!(attributes)
      end

      def redirects_csv_path
        "#{Core::Engine.root}/test/fixtures/redirects.csv"
      end

      def redirects_fail_csv_path
        "#{Core::Engine.root}/test/fixtures/redirects_fail.csv"
      end
    end
  end
end
