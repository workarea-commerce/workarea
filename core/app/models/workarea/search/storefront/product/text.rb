module Workarea
  module Search
    class Storefront
      class Product
        module Text
          def catalog_content
            [model.browser_title, model.meta_description, model.description]
              .reject(&:blank?)
              .join(' ')
          end

          # A list of category names to which this product belongs,
          # allows finding products by category names in search.
          #
          # @return [String]
          #
          def category_names
            categorization.to_models.map(&:name).join(', ')
          end

          # A textual version of the product's filters hash that
          # will be stored and analyzed in the search index.
          #
          # @return [String]
          #
          def facets_content
            HashText.new(model.filters).text
          end

          # A textual version of the product's filters hash that
          # will be stored and analyzed in the search index.
          #
          # @return [String]
          #
          def details_content
            "#{HashText.new(model.details).text} #{variant_details_text}"
          end

          # Text from the product's details hash and it's variants' details
          # hash. Allows finding a product by one of these values.
          #
          # @return [String]
          #
          def details
            "#{HashText.new(model.details).text} #{variant_details_text}"
          end

          # Content to put in the index for making search query suggestions.
          # Includes all content for the product.
          #
          # @return [String]
          #
          def suggestion_content
            [
              model.name,
              category_names,
              facets_content,
              details_content
            ].join(' ')
          end

          def variant_details_text
            @variant_details_text ||= model.variants.active.map do |variant|
              "#{variant.name} #{HashText.new(variant.details).text}"
            end.join(' ')
          end
        end
      end
    end
  end
end
