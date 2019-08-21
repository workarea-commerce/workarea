module Workarea
  module Storefront
    module ProductsHelper
      def truncated_product_description(product, text)
        truncate(strip_tags(product.description), length: 200) do
          link_to(
            text,
            product_path(
              product,
              params: product.browse_link_options,
              anchor: 'description'
            ),
            data: {
              scroll_to_button: ''
            }
          )
        end
      end

      def option_label(option)
        if option.current.present?
          "#{option.name}: #{option.current}"
        else
          option.name
        end
      end

      def option_selection_url_for(product, option, selection)
        selection_value = option.current == selection ? nil : selection
        product.currently_selected_options.merge(
          option.slug => selection_value,
          id: product.slug,
          via: params[:via]
        )
      end

      def intrinsic_ratio_product_image_styles(image)
        return if image.inverse_aspect_ratio.blank?
        "padding-bottom: #{image.inverse_aspect_ratio * 100}%;"
      end
    end
  end
end
