module Workarea
  module Storefront
    class ProductViewModel
      class CacheKey
        def initialize(product, options = {})
          @product = product
          @options = options
        end

        def to_s
          (product_parts + option_parts).join('/')
        end

        private

        # This method exists to duplicate Mongoid cache for a Catalog::Product
        # that has been loaded from Elasticsearch. Since not persisted, Mongoid
        # returns a hardcoded cache key.
        def product_parts
          [
            @product.send(:model_key), # Mongoid has this as a private method
            "#{@product.id}-#{@product.updated_at.utc.to_s(:nsec)}"
          ]
        end

        def option_parts
          common_options.values + details_in_options.values
        end

        def details_in_options
          @options.select { |option, _value| detail_keys.include?(option&.systemize) }
        end

        def common_options
          @options.slice(:current_sku, :via)
        end

        def detail_keys
          @product.variants.flat_map(&:detail_names).map(&:systemize).uniq
        end
      end
    end
  end
end
