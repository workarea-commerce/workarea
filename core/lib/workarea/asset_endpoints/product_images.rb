module Workarea
  module AssetEndpoints
    class ProductImages < Base
      def result
        Catalog::Product
          .find_by(slug: params[:slug])
          .images
          .find(params[:image_id])
          .process(params[:job])

      rescue Mongoid::Errors::DocumentNotFound
        Catalog::ProductPlaceholderImage.cached.process(params[:job])
      end
    end
  end
end
