module Workarea
  module Admin
    module Discounts
      class CategoryViewModel < DiscountViewModel
        include Categories

        def condition_options
          [
            [
              t('workarea.admin.pricing_discounts.options.for_everyone'),
              nil
            ],
            [
              t('workarea.admin.pricing_discounts.options.when_order_total'),
              'order_total'
            ],
            [
              t('workarea.admin.pricing_discounts.options.when_item_quantity'),
              'item_quantity'
            ],
            [
              t('workarea.admin.pricing_discounts.options.when_user_is_tagged'),
              'user_tag'
            ],
            [
              t('workarea.admin.pricing_discounts.options.when_in_segment'),
              'segments'
            ]
          ]
        end

        def selected_condition_option
          if use_order_total?
            'order_total'
          elsif item_quantity?
            'item_quantity'
          elsif user_tag?
            'user_tag'
          elsif active_segment_ids.present?
            'segments'
          end
        end
      end
    end
  end
end
