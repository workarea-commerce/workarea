module Workarea
  module Storefront
    module CatalogCustomizationTestClass
      extend ActiveSupport::Concern

      included do
        setup :add_customization_class
        teardown :remove_customization_class
      end

      def add_customization_class
        Workarea::Catalog::Customizations.const_set(
          'FooCust',
          Class.new(Catalog::Customizations) do
            customized_fields :foo, :bar

            validates :foo, presence: true
            validates :bar, presence: true
          end
        )
      end

      def remove_customization_class
        Workarea::Catalog::Customizations.send(:remove_const, 'FooCust')
      end
    end
  end
end
