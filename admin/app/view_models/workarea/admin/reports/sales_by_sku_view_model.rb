module Workarea
  module Admin
    module Reports
      class SalesBySkuViewModel < ApplicationViewModel
        def results
          @results ||= model.results.map do |result|
            product = products.detect { |p| p.skus.include?(result['_id']) }
            OpenStruct.new({ product: product }.merge(result))
          end
        end

        def products
          @products ||= Catalog::Product.any_in(
            'variants.sku' => model.results.map { |r| r['_id'] }
          ).to_a
        end
      end
    end
  end
end
