module Workarea
  module Admin
    class ProductViewModel < ApplicationViewModel
      include CommentableViewModel

      delegate :primary_image, :show_original_range?,
        :original_min_price, :original_max_price,
        to: :storefront_view_model, allow_nil: true

      delegate :sell_min_price, :sell_max_price, :on_sale?,
        :has_prices?, to: :pricing

      def timeline
        @timeline ||= TimelineViewModel.new(model)
      end

      def categorization
        @categorization ||= Categorization.new(model)
      end

      def categories
        @categories ||= CategoryViewModel.wrap(categorization.to_models)
      end

      def rules_categories
        @rules_categories ||=
          categories.reject { |c| c.featured_product?(model.id) }
      end

      def featured_categories
        @featured_categories ||=
          categories.select { |c| c.featured_product?(model.id) }
      end

      def default_category
        return @default_category if defined? @default_category
        @default_category = if categorization.default_model.present?
          CategoryViewModel.wrap(categorization.default_model)
        end
      end

      def storefront_view_model
        @storefront_view_model ||= Storefront::ProductViewModel.wrap(
          model,
          options
        )
      end

      def pricing
        @pricing ||= options[:pricing] || Pricing::Collection.new(
          options[:sku].presence || model.variants.map(&:sku)
        )
      end

      def one_price?
        return false if sell_min_price.nil? || original_min_price.nil?
        sell_min_price >= original_min_price
      end

      def show_sell_range?
        return false if sell_min_price.nil? || sell_max_price.nil?
        sell_min_price < sell_max_price
      end

      def pricing?
        storefront_view_model.present?
      end

      def variant_sell_price(variant)
        pricing.for_sku(variant.sku).sell
      end

      def sales
        @sales ||= Inventory.total_sales(*model.skus)
      end

      def available_inventory
        @available_inventory ||= Inventory::Collection.new(model.skus).available_to_sell
      end

      def ignore_inventory?
        return @ignore_inventory if defined?(@ignore_inventory)
        @ignore_inventory ||= inventory.all?(&:ignore?)
      end

      def templates
        [
          [t('workarea.admin.catalog_products.templates.generic'), 'generic']
        ] + Workarea.config.product_templates.reject do |template|
          template.to_s.include?('test')
        end.sort.map(&:to_s).map do |template_name|
          [template_name.titleize, template_name.optionize]
        end
      end

      def variant_details
        variants.each_with_object({}) do |variant, memo|
          variant.details.each do |name, value|
            memo[name] ||= []
            memo[name] += Array.wrap(value)
            memo[name].uniq!
          end
        end
      end

      def customization_options
        default_customization_options + configured_customization_options
      end

      def images_by_option
        images.asc(:position).group_by do |image|
          image.option.to_s.titleize
        end
      end

      def content
        @content ||= Content.for(model)
      end

      def storefront_recommendations
        storefront_view_model.recommendations
      end

      def insights
        @insights ||= Insights::ProductViewModel.wrap(model, options)
      end

      def inventory
        @inventory ||=
          options[:inventory] || Inventory::Collection.new(model.skus)
      end

      def displayable?
        active? && inventory.any?(&:displayable?)
      end

      def inventory_message
        @inventory_message ||=
          if !active?
            t('workarea.admin.featured_products.statuses.inactive')
          elsif inventory.backordered?
            t('workarea.admin.featured_products.statuses.backordered')
          elsif inventory.out_of_stock?
            t('workarea.admin.featured_products.statuses.out_of_stock')
          elsif inventory.low_inventory?
            t(
              'workarea.admin.featured_products.statuses.low_inventory',
              count: inventory.available_to_sell
            )
          else
            ''
          end
      end

      private

      def default_customization_options
        [[t('workarea.admin.catalog_products.customizations.none'), nil]]
      end

      def configured_customization_options
        Workarea.config.customization_types
          .map(&:to_s)
          .map(&:demodulize)
          .map do |type|
            [type.titleize, type.underscore]
          end
      end
    end
  end
end
