module Workarea
  module Admin
    module Reports
      class SalesByProductViewModel < ApplicationViewModel
        def results
          @results ||= model.results.map do |result|
            OpenStruct.new({ product: products[result['_id']] }.merge(result))
          end
        end

        def products
          @products ||= Catalog::Product.any_in(id: model.results.map { |r| r['_id'] }).to_lookup_hash
        end
      end
    end
  end
end
