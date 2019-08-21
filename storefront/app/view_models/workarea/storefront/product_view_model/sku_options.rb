module Workarea
  module Storefront
    class ProductViewModel
      class SkuOptions
        def initialize(variants)
          @variants = variants
        end

        def to_a
          if options.one?
            options
          else
            [[::I18n.t('workarea.storefront.products.select_options'), nil]] +
              options
          end
        end

        private

        def options
          @variants.map { |variant| [text_for_variant(variant), variant.sku, options_for_variant(variant)] }
        end

        def options_for_variant(variant)
          {
            data: {
              sku_option_details: json_details_for_variant(variant)
            }
          }
        end

        def json_details_for_variant(variant)
          return {}.to_json unless variant.details.present?
          variant.details.map { |k, v| [k.systemize, v] }.to_h.to_json
        end

        def text_for_variant(variant)
          if variant.name != variant.sku
            variant.name
          elsif variant.details.blank?
            variant.sku
          else
            details = variant.details.map do |k, v|
              "#{k.titleize}: #{[v].flatten.join(', ')}"
            end

            "#{variant.sku} - #{details.join(', ')}"
          end
        end
      end
    end
  end
end
