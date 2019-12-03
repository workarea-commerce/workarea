module Workarea
  module Admin
    module ContentBlockIconHelper
      # This is a direct copy from the `inline_svg` helper, in order to give us
      # better control over the `rescue` state.
      # https://github.com/jamesmartin/inline_svg/blob/v1.2.1/lib/inline_svg/action_view/helpers.rb
      def content_block_icon(filename, transform_params={})
        begin
          svg_file = if InlineSvg::IOResource === filename
            InlineSvg::IOResource.read filename
                     else
            configured_asset_file.named filename
          end
        rescue InlineSvg::AssetFile::FileNotFound
          return inline_svg_tag('workarea/admin/content_block_types/custom_block.svg', transform_params)
        end

        InlineSvg::TransformPipeline.generate_html_from(svg_file, transform_params).html_safe
      end
    end
  end
end
