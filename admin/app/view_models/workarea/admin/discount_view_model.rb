module Workarea
  module Admin
    class DiscountViewModel < ApplicationViewModel
      include CommentableViewModel

      def self.wrap(model, options = {})
        if model.is_a?(Enumerable)
          model.map { |m| wrap(m, options) }
        elsif NewDiscount.valid_class?(model.class)
          slug = model.class.name.demodulize
          view_model_class = "Workarea::Admin::Discounts::#{slug}ViewModel"
          view_model_class.constantize.new(model, options)
        else
          new(model, options)
        end
      end

      def insights
        @insights ||= Insights::DiscountViewModel.wrap(model, options)
      end

      def timeline
        @timeline ||= TimelineViewModel.new(model)
      end

      def slug
        model.class.name.demodulize.underscore
      end

      def rules_summary
        @rules_summary ||= DiscountRulesViewModel.new(model).to_h
      end

      def amount_type_options
        [[Money.default_currency.symbol, 'flat'], ['%', 'percent']]
      end

      def max_applications_options
        (1..5).to_a.unshift(
          [
            t('workarea.admin.pricing_discounts.options.unlimited_applications'),
            nil
          ]
        )
      end

      def promo_code_options
        [
          [
            t('workarea.admin.pricing_discounts.options.promo_code_is'),
            'promo_codes_list'
          ],
          [
            t('workarea.admin.pricing_discounts.options.promo_code_is_from'),
            'generated_codes_id'
          ]
        ]
      end

      def selected_promo_code_option
        if generated_codes_id.present?
          'generated_codes_id'
        else
          'promo_codes_list'
        end
      end

      def application_options
        [
          [
            t('workarea.admin.pricing_discounts.options.application_automatically'),
            nil
          ],
          [
            t('workarea.admin.pricing_discounts.options.application_promo_code'),
            'promo_code'
          ]
        ]
      end

      def selected_application_option
        if promo_code?
          'promo_code'
        end
      end

      def workflow_params
        params = { discount: { name: model.name, tag_list: model.tag_list } }
        params.merge!(options.slice(:type, :discount))
        params[:id] = model.id if model.persisted?
        params
      end

      def order_total_operator_options
        Pricing::Discount::Conditions::OrderTotal::OPERATORS.map do |op|
          [op.to_s.humanize.downcase, op]
        end
      end

      def code_list_options
        @code_list_options ||= [
          [t('workarea.admin.pricing_discounts.options.code_list_select'), nil]
        ] + Pricing::Discount::CodeList.all.map do |code_list|
          [code_list.name, code_list.id]
        end
      end

      def compatible_discounts
        @compatible_discounts ||= Pricing::Discount
          .where(:id.in => compatible_discount_ids)
          .to_a
      end

      def excluded_categories
        @excluded_categories ||= Catalog::Category.in(
          id: excluded_category_ids
        )
      end

      def excluded_products
        @excluded_products ||= Catalog::Product.in(
          id: excluded_product_ids
        )
      end
    end
  end
end
