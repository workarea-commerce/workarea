module Workarea
  module Admin
    class BulkActionProductEditViewModel < ApplicationViewModel
      def template_options
        ProductViewModel.new.templates
      end

      def selected?(hash, field)
        model.send(hash).key?(field)
      end

      def selected_true?(hash, field)
        !selected?(hash, field) || send(hash)[field] == 'true'
      end

      def selected_false?(hash, field)
        send(hash)[field] == 'false'
      end

      def pricing_prices
        pricing['prices'] || {}
      end

      def segments
        return [] if settings['active_segment_ids'].blank?
        @segments ||= Segment.in(id: settings['active_segment_ids']).to_a
      end

      def pricing_actions
        [
          [
            t('workarea.admin.bulk_action_product_edits.pricing.set'),
            'set'
          ],
          [
            t('workarea.admin.bulk_action_product_edits.pricing.increase'),
            'increase'
          ],
          [
            t('workarea.admin.bulk_action_product_edits.pricing.decrease'),
            'decrease'
          ]
        ]
      end

      def pricing_types
        [
          [
            Money.default_currency.symbol,
            'flat'
          ],
          [
            t('workarea.admin.bulk_action_product_edits.pricing.percentage'),
            'percentage'
          ]
        ]
      end
    end
  end
end
