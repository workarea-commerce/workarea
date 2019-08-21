module Workarea
  module Search
    class Admin
      class CatalogCategory < Search::Admin
        include Admin::Releasable

        def search_text
          "category #{model.name}"
        end

        def jump_to_text
          model.name
        end

        def jump_to_position
          4
        end

        def facets
          super.merge(issues: issues)
        end

        def displayable_products
          view_model = Workarea::Storefront::CategoryViewModel.wrap(model)
          return [] unless view_model.respond_to?(:products)

          view_model.products
        end

        # This funny business exists because displayable_products depends on
        # product browse indexing, which will be delayed (async).
        #
        def has_products?
          if displayable_products.blank? && model.product_ids.present?
            # Simulate whether it will show up
            # TODO FIX, this is a HACK please forgive my cursed soul
            products = Catalog::Product.any_in(id: model.product_ids.take(100))
            products.any? do |product|
              search_model = Storefront::Product.new(product)

              product.active? &&
                search_model.variant_count > 0 &&
                search_model.inventory.available_to_sell > 0
            end
          else
            displayable_products.present?
          end
        end

        def issues
          result = []
          result << I18n.t('workarea.alerts.issues.no_displayable_products') unless has_products?
          result << I18n.t('workarea.alerts.issues.not_in_taxonomy') unless model.taxon.present?
          result
        end

        def as_document
          super.merge(breadcrumbs: breadcrumbs)
        end

        def breadcrumbs
          Workarea::Navigation::Breadcrumbs.new(model).join(' > ')
        end
      end
    end
  end
end
