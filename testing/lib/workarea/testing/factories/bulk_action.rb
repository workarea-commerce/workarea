module Workarea
  module Factories
    module BulkAction
      Factories.add(self)

      def create_sequential_product_edit(overrides = {})
        attributes = factory_defaults(:sequential_product_edit).merge(overrides)
        Workarea::BulkAction::SequentialProductEdit.create!(attributes)
      end

      def create_bulk_action_product_edit(overrides = {})
        attributes = factory_defaults(:bulk_action_product_edit).merge(overrides)
        Workarea::BulkAction::ProductEdit.create!(attributes)
      end
    end
  end
end
