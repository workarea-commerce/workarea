module Workarea
  module Search
    class Admin
      class InventorySku < Search::Admin
        def type
          'inventory_sku'
        end

        def search_text
          model.name
        end

        def jump_to_text
          I18n.t(
            'workarea.inventory_sku.jump_to_text',
            id: model.id,
            count: model.available_to_sell
          )
        end

        def jump_to_position
          12
        end

        def facets
          super.merge(policy: model.policy)
        end
      end
    end
  end
end
