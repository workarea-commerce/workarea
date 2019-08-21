module Workarea
  class Lint
    class ProductsMissingVariants < Lint
      def run
        Catalog::Product
          .any_of({ variants: nil }, { variants: [] })
          .each_by(100) do |product|
            error("#{product.id},No variants")
          end
      end
    end
  end
end
