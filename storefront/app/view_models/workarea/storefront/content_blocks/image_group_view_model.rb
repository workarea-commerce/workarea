module Workarea
  module Storefront
    module ContentBlocks
      class ImageGroupViewModel < ContentBlockViewModel
        def link
          data[:link]
        end

        def asset
          find_asset(data[:image])
        end

        def alt
          data[:alt]
        end

        # TODO v4 remove
        def odd?
          series.size.odd?
        end
      end
    end
  end
end
