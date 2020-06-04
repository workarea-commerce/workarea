module Workarea
  module Search
    class Admin
      class PricingDiscount < Search::Admin
        include Admin::Releasable

        def type
          'discount'
        end

        def search_text
          "discount #{model.name}"
        end

        def jump_to_text
          model.name
        end

        def jump_to_position
          9
        end

        def keywords
          super + Array.wrap(model.try(:promo_codes))
        end

        def facets
          super.merge(discount_type: model.class.name.demodulize.titleize)
        end

        def as_document
          super.merge(total_redemptions: model.redemptions.count)
        end
      end
    end
  end
end
