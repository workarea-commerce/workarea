module Workarea
  module AssetEndpoints
    class ProductPlaceholderImages < Base
      def result
        Catalog::ProductPlaceholderImage.cached.process(params[:job])
      end
    end
  end
end
