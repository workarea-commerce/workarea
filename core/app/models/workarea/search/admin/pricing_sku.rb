module Workarea
  module Search
    class Admin
      class PricingSku < Search::Admin
        include Admin::Releasable

        def type
          'pricing_sku'
        end

        def search_text
          model.name
        end

        def jump_to_text
          "#{model.id} - #{model.sell_price.format}"
        end

        def jump_to_position
          11
        end
      end
    end
  end
end
