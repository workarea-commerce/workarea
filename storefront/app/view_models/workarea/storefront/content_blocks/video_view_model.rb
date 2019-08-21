module Workarea
  module Storefront
    module ContentBlocks
      class VideoViewModel < ContentBlockViewModel
        def locals
          super.merge(
            frame_styles: frame_styles,
            embed: embed
          )
        end

        def frame_styles
          aspect_ratio.present? ? "padding-bottom: #{aspect_ratio}%; height: 0;" : nil
        end

        def embed
          raw_embed
            .gsub(
              /<iframe/,
              "<iframe title='#{t('workarea.storefront.content_blocks.video', url: video_url)}'"
            )
            .gsub(/ frameborder=["'][^"']*["']/, '')
        end

        private

        def aspect_ratio
          return nil if width.nil? || height.nil?
          height / width * 100
        end

        def width
          find_dimension(/width=["'](\d+)["']/)
        end

        def height
          find_dimension(/height=["'](\d+)["']/)
        end

        def find_dimension(regex)
          results = raw_embed.match(regex)
          if results.present?
            value = results.captures[0].to_f
            value > 0 ? value : nil
          end
        end

        def raw_embed
          model.data['embed'] || ''
        end

        def video_url
          raw_embed.match(/https?:\/\/[\S]+/)[0]
        end
      end
    end
  end
end
