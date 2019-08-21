module Workarea
  class Lint
    class ProductsMissingImages < Lint
      def run
        Catalog::Product
          .any_of({ images: nil }, { images: [] })
          .each_by(100) do |product|
            warn("#{product.id},No images")
          end
      end
    end
  end
end
