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
          "#{model.id} (#{model.available} available)"
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
