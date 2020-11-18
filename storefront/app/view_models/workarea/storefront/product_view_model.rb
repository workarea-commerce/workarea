module Workarea
  module Storefront
    class ProductViewModel < ApplicationViewModel
      def self.wrap(model, options = {})
        if model.is_a?(Enumerable)
          model.map { |m| wrap(m, options) }
        elsif Workarea.config.product_templates.include?(model.template.to_sym)
          view_model_class = "Workarea::Storefront::ProductTemplates::#{model.template.camelize}ViewModel"
          view_model_class.constantize.new(model, options)
        else
          new(model, options)
        end
      rescue NameError
        new(model, options)
      end

      def breadcrumbs
        @breadcrumbs ||=
          if options[:via].present?
            Navigation::Breadcrumbs.from_global_id(
              options[:via],
              last: model
            )
          else
            Navigation::Breadcrumbs.new(
              default_category,
              last: model
            )
          end
      end

      def primary_image
        images.primary
      end

      def images
        @images_collection ||=
          Storefront::ProductViewModel::ImageCollection.new(model, options)
      end

      def cache_key
        @cache_key ||= CacheKey.new(
          model,
          options.merge(current_sku: current_sku)
        ).to_s
      end

      #
      # Browsing
      #
      #

      def catalog_id
        options[:catalog_id]
      end

      def browse_link_options
        @browse_link_options ||= options.slice(:via).with_indifferent_access
      end

      # Returns the set of recommendations for the product.
      # The view model it returns behave like {Enumerable}.
      #
      # @return [Workarea::Storefront::DetailPageRecommendationsViewModel]
      #
      def recommendations
        @recommendations ||= DetailPageRecommendationsViewModel.new(model, options)
      end

      #
      # Pricing
      #
      #

      delegate :sell_min_price, :sell_max_price, :on_sale?, :has_prices?, to: :pricing

      def pricing
        @pricing ||= options[:pricing] || Pricing::Collection.new(
          options[:sku].presence || variants.map(&:sku)
        )
      end

      def purchasable?
        has_prices? && model.purchasable? && inventory_purchasable?
      end

      def one_price?
        return false if sell_min_price.nil?
        sell_min_price >= original_min_price
      end

      def show_sell_range?
        return false if sell_min_price.nil? || sell_max_price.nil?
        sell_min_price < sell_max_price
      end

      def show_original_range?
        return false if original_min_price.nil? || original_max_price.nil?
        original_min_price < original_max_price
      end

      def original_min_price
        return nil unless has_prices?

        if pricing.msrp_min_price.present? && pricing.msrp_min_price > sell_min_price
          pricing.msrp_min_price
        else
          pricing.regular_min_price
        end
      end

      def original_max_price
        return nil unless has_prices?

        if pricing.msrp_max_price.present? && pricing.msrp_max_price > sell_max_price
          pricing.msrp_max_price
        else
          pricing.regular_max_price
        end
      end

      #
      # Variants
      #
      #

      def variants
        @variants ||= model.variants.active.select do |variant|
          !!inventory.for_sku(variant.sku).try(:displayable?)
        end
      end

      def current_sku
        options[:sku]
      end

      def current_variant
        variants.detect { |variant| variant.sku == current_sku }
      end

      def sku_options
        @sku_options ||= SkuOptions.new(variants).to_a
      end

      def inventory
        @inventory ||= options[:inventory] ||
          Inventory::Collection.new(model.variants.map(&:sku))
      end

      def inventory_status
        InventoryStatusViewModel.new(inventory.for_sku(current_sku)).message
      end

      def inventory_purchasable?
        current_sku.blank? || inventory.for_sku(current_sku).purchasable?
      end

      def default_category
        @default_category ||= Categorization.new(model).default_model
      end

      #
      # Detail
      #
      #

      def browser_title
        if model.browser_title.present?
          model.browser_title
        else
          model.name
        end
      end

      def meta_description
        if model.meta_description.present?
          model.meta_description
        else
          model.description
        end
      end

      #
      # Fulfillment
      #
      #

      def fulfillment_skus
        @fulfillment_skus ||=
          Fulfillment::Sku.find_or_initialize_all(variants.map(&:sku))
      end

      def requires_shipping?
        if current_variant.present?
          fulfillment_skus
            .detect { |sku| sku.id == current_variant.sku }
            .shipping?
        else
          fulfillment_skus.any?(&:shipping?)
        end
      end
    end
  end
end
