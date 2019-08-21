module Workarea
  module Storefront
    class ProductViewModel
      class ImageCollection
        include Enumerable

        attr_reader :all

        def initialize(product, options = {}, images = nil)
          @product = product
          @options = options.with_indifferent_access
          @all = images || @product.images
        end

        def primary
          @primary ||= selected_facet_images ||
                       first ||
                       Catalog::ProductPlaceholderImage.cached
        end

        def +(other)
          ImageCollection.new(@product, @options, @all + other.all)
        end

        def respond_to_missing?(method_name, include_private = false)
          super || @all.respond_to?(method_name)
        end

        def method_missing(sym, *args, &block)
          if @all.respond_to?(sym)
            @all.send(sym, *args, &block)
          else
            super
          end
        end

        private

        def selected_facet_images
          return unless selected_facet_values.present?
          @all.detect { |i| i.option.to_s.systemize.in?(selected_facet_values) }
        end

        def selected_facet_values
          @selected_facet_values ||=
            if @options[:sku].present?
              variant = @product.variants.find_by(sku: @options[:sku])
              variant.details.values.flatten.map(&:systemize)
            else
              @options.values.flat_map do |value|
                Array.wrap(value).map(&:to_s).map(&:optionize)
              end
            end
        end
      end
    end
  end
end
