module Workarea
  module Admin
    class DiscountRulesViewModel < ApplicationViewModel
      def to_h
        displayed_fields.reduce({}) do |memo, field|
          value = if respond_to?(field)
                    send(field)
                  else
                    model.send(field)
                  end

          memo[clean_field_name(field)] = value if value.present?
          memo
        end
      end

      def amount_type
        nil
      end

      def amount
        if model.respond_to?(:amount_type) && model.amount_type == :percent
          "#{model.amount.to_i}%"
        else
          ActionController::Base.helpers.number_to_currency(model.amount)
        end
      end

      def item_quantity
        if model.item_quantity.to_i > 0
          model.item_quantity
        end
      end

      def product_id
        nil
      end

      def product_ids
        find_models(Catalog::Product, model.product_ids)
      end

      def category_ids
        find_models(Catalog::Category, model.category_ids)
      end

      def promo_codes
        model.promo_codes.map(&:upcase).join(', ')
      end

      def order_total_operator
        if model.order_total.present? && model.order_total > 0
          model.order_total_operator.to_s.humanize.downcase
        end
      end

      def order_total
        return nil if model.order_total.blank?
        model.order_total > 0 ? model.order_total : nil
      end

      def generated_codes_id
        if model.generated_codes_id.present?
          Pricing::Discount::CodeList
            .where(id: model.generated_codes_id)
            .first
            .try(:name)
        end
      end

      def displayed_fields
        model.class.fields.except(*ignored_fields).keys
      end

      def ignored_fields
        Workarea::Pricing::Discount.fields.keys
      end

      private

      def clean_field_name(field)
        result = field.gsub(/_ids?$/, '')
        result = result.pluralize if field.ends_with?('s')
        result.titleize
      end

      def find_models(klass, ids)
        ids = Array.wrap(ids).reject(&:blank?)
        return if ids.blank?

        models = klass.any_in(id: ids).desc(:created_at).to_a
        return unless models.present?
        result = [models.first.name.dup]
        result << t('workarea.admin.cards.more', amount: models.length - 1) if models.many?
        result.join(' ')
      end
    end
  end
end
