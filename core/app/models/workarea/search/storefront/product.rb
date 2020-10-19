module Workarea
  module Search
    class Storefront
      class Product < ::Workarea::Search::Storefront
        include Product::Pricing
        include Product::Inventory
        include Product::Categories
        include Product::Text
        include Product::Sorting
        include Product::Facets
        include Product::Analytics

        def facets
          result = model.filters.reduce({}) do |memo, (key, value)|
            memo[key.to_s.systemize] = FacetValues.sanitize(value)
            memo
          end

          result[:category] = primary_navigation if primary_navigation.present?

          result.merge(
            category_id: category_id,
            on_sale: on_sale?,
            inventory_policies: inventory.policies
          )
        end

        def numeric
          {
            price: price,
            inventory: inventory.available_to_sell,
            variant_count: variant_count
          }
        end

        # Fields for exact matching
        def keywords
          {
            catalog_id: clean_for_keywords(catalog_id),
            sku: sku.map { |s| clean_for_keywords(s) },
            name: clean_for_keywords(model.name),
            tags: model.tags
          }
        end

        def sorts
          category_positions
            .merge(search_positions)
            .merge(
              price: sort_price,
              orders_score: orders_score,
              views_score: views_score,
              inventory_score: inventory_score
            )
        end

        def content
          {
            name: model.name,
            category_names: category_names,
            description: catalog_content,
            details: details_content,
            facets: facets_content
          }
        end

        def cache
          {
            image: primary_image,
            pricing: pricing.records.map do |model|
              Elasticsearch::Serializer.serialize(model)
            end,
            inventory: inventory.records.map do |model|
              Elasticsearch::Serializer.serialize(model)
            end
          }
        end

        # SKUs to be added to the search index. Allows searching
        # for a SKU that is setup under a product.
        #
        # @return [Array]
        #
        def sku
          return [] unless skus.present?
          inventory.select(&:displayable?).map(&:id)
        end

        # The SKUs to be used for gathering pricing, inventory, display
        # data. Show be
        #
        # @return [Array<String>]
        #
        def skus
          model.variants.active.map(&:sku).uniq
        end

        # Number of active variants the product has. Used to filter out
        # products that have no variants from browse pages because
        # they won't have displayable data.
        #
        # @return [Integer]
        #
        def variant_count
          model.variants.active.length
        end

        # The ID of the corresponding {Catalog::Product}. Used
        # to determine what product to load for display details
        # on browse pages.
        #
        # @return [String]
        #
        def catalog_id
          CGI.escape(model.id)
        end

        # URL to the primary image for display in autocomplete results.
        #
        # @return [String]
        #
        def primary_image
          ProductPrimaryImageUrl.new(model).path
        end

        def changesets
          ProductReleases.new(model).changesets
        end

        private

        def clean_for_keywords(value)
          value.to_s.squeeze(' ').strip.downcase
        end
      end
    end
  end
end
