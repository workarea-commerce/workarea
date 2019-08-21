module Workarea
  module Search
    class Storefront
      class Product
        module Facets
          extend ActiveSupport::Concern

          module ClassMethods
            # A hash representing current fields available for product rules. Keys
            # are the displayable name, values are the fields as mapped in the
            # search index.
            #
            # @return [Hash]
            #
            def current_product_rule_fields
              Workarea.config.product_rule_fields.merge(
                Workarea::Search::Settings.current.terms_facets.reduce({}) do |memo, facet|
                  memo[facet] = "facets.#{facet.systemize}"
                  memo
                end
              )
            end

            # The current facets to use when searching for products.
            #
            # @return [Array<String>]
            #
            def current_terms_facets
              ['category'] + Workarea::Search::Settings.current.terms_facets
            end
          end

          # Fields for faceting, as defined by the contents of the
          # filters hash on the {Catalog::Product}.
          #
          # @return [Hash]
          #
          def facets
            result = model.filters.reduce({}) do |memo, tuple|
              key, value = *tuple
              memo[key.to_s.systemize] = FacetValues.sanitize(value)
              memo
            end

            result[:category] = primary_navigation if primary_navigation.present?
            result[:category_id] = category_id
            result
          end

          private

          def primary_navigation
            @primary_navigation ||= ProductPrimaryNavigation.new(
              model,
              categories: categorization.to_models
            ).name
          end
        end
      end
    end
  end
end
