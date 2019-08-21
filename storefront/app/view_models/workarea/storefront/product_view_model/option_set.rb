module Workarea
  module Storefront
    class ProductViewModel
      class OptionSet
        attr_reader :product, :options

        def self.from_sku(product, sku, options = {})
          matching_variant = product.variants.detect { |v| v.sku == sku }
          sku_options = matching_variant&.details&.transform_values(&:first) || {}
          new(product, sku_options.merge(options))
        end

        def initialize(product, options = {})
          @product = product
          @options = options.transform_keys { |k| k.to_s.optionize }
        end

        def all_options
          @all_options ||= product
            .variants
            .flat_map { |v| v.details.keys }
            .uniq
            .map { |o| o.to_s.optionize }
        end

        def currently_selected_options
          @currently_selected_options ||= options_with_one_value.merge(
            options.select do |key|
              key.optionize.in?(all_options) && options[key.optionize].present?
            end
          )
        end

        def options_for_selection
          @options_for_selection ||=
            begin
              result = all_options.reduce([]) do |memo, key|
                variants_with_this = product.variants.select { |v| v.has_detail?(key) }
                all_values = variants_with_this.map { |v| v.fetch_detail(key) }.flatten.uniq
                values = values_based_on_other_options(key, all_values)

                if values.any?
                  memo << Option.new(
                    product,
                    key,
                    values,
                    currently_selected_options
                  )
                end

                memo
              end

              Workarea.config.option_selections_sort.call(product, result)
            end
        end

        def current_variant
          return nil if currently_selected_options.blank?

          @current_variant ||= product.variants.detect do |variant|
            variant.details.size == currently_selected_options.size &&
              variant.matches_details?(currently_selected_options)
          end
        end

        def current_sku
          return nil if currently_selected_options.blank?
          current_variant.try(:sku)
        end

        private

        def values_based_on_other_options(key, values)
          values.select do |value|
            product.variants.any? do |variant|
              variant.matches_details?(
                currently_selected_options.merge(key => value)
              )
            end
          end
        end

        def options_with_one_value
          all_options.each_with_object({}) do |key, memo|
            variants_with_this = product.variants.select { |v| v.has_detail?(key) }
            all_values = product.variants.flat_map { |v| v.fetch_detail(key) }.uniq

            if variants_with_this.size == product.variants.size && all_values.one?
              memo.merge!(key => all_values.first)
            end
          end
        end
      end
    end
  end
end
