module Workarea
  module Search
    class Admin
      class CatalogProduct < Search::Admin
        include Admin::Releasable

        def status
          if model.active?
            'active'
          else
            'inactive'
          end
        end

        def search_text
          [
            model.id, model.name, model.skus, variant_names,
            category_ids, filter_values, 'product'
          ].flatten
        end

        def keywords
          super + model.skus + category_ids
        end

        def jump_to_text
          "#{model.name} (#{model.id})"
        end

        def jump_to_search_text
          [
            model.id, model.name, model.skus, variant_names,
            category_ids, 'product'
          ].flatten
        end

        def filter_values
          model.filters.values.flatten
        end

        def jump_to_position
          3
        end

        def facets
          super
            .merge(Search::Storefront::Product.new(model).facets)
            .merge(
              issues: issues,
              template: model.template
            )
        end

        def category_ids
          @category_ids ||= model.category_ids
        end

        def variant_names
          model.variants.map(&:name)
        end

        def issues
          result = []

          result << I18n.t('workarea.alerts.issues.no_images') if model.images.blank?
          result << I18n.t('workarea.alerts.issues.no_description') if model.description.blank?
          result << I18n.t('workarea.alerts.issues.no_variants') if model.variants.blank?
          result << I18n.t('workarea.alerts.issues.no_categories') if Workarea::Categorization.new(model).blank?
          result << I18n.t('workarea.alerts.issues.sku_missing_price') if sku_without_price?
          result << I18n.t('workarea.alerts.issues.low_inventory') if low_inventory?
          result << I18n.t('workarea.alerts.issues.variants_missing_details') if variant_missing_details?
          result << I18n.t('workarea.alerts.issues.inconsistent_variant_details') if inconsistent_variant_details?

          result
        end

        def sku_without_price?
          pricing_skus = Pricing::Sku.any_in(id: model.skus).map(&:id)
          model.skus.any? { |s| !s.in?(pricing_skus) }
        end

        def low_inventory?
          Inventory::Collection.new(model.skus).low_inventory?
        end

        def variant_missing_details?
          model.variants.any? { |v| v.details.blank? }
        end

        def inconsistent_variant_details?
          details = model.variants.map(&:details).flat_map(&:keys).uniq
          model.variants.any? { |v| (details - v.details.keys).present? }
        end
      end
    end
  end
end
