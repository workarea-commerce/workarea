module Workarea
  module Storefront
    class ProductViewModel
      class Option
        attr_reader :product, :slug, :selections, :options

        def initialize(product, slug, selections, options = {})
          @product = product
          @slug = slug.optionize
          @selections = selections
          @options = options
        end

        def name
          slug.titleize
        end

        def current
          options[slug].presence_in(selections)
        end
      end
    end
  end
end
