module Workarea
  module Search
    class Admin
      class ShippingSku < Search::Admin
        def type
          'shipping_sku'
        end

        def search_text
          model.name
        end

        def jump_to_text
          "#{model.id} - #{view_model.weight}"
        end

        def jump_to_position
          12
        end

        def view_model
          @view_model ||= Workarea::Admin::ShippingSkuViewModel.wrap(model)
        end
      end
    end
  end
end
