module Workarea
  module Admin
    module Reports
      class SalesByCategoryViewModel < ApplicationViewModel
        def results
          @results ||= model.results.map do |result|
            OpenStruct.new({ category: categories[result['_id']] }.merge(result))
          end
        end

        def categories
          @categories ||= Catalog::Category.any_in(id: model.results.map { |r| r['_id'] }).to_lookup_hash
        end
      end
    end
  end
end
