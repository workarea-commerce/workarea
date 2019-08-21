module Workarea
  module Search
    class Admin
      class FulfillmentSku < Search::Admin
        def type
          'fulfillment_sku'
        end

        def search_text
          model.name
        end

        def jump_to_text
          "#{model.id} - (#{model.policy})"
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
