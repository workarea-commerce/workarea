module Workarea
  module Admin
    module Reports
      class SalesByCategoryViewModel < ApplicationViewModel
        def results
          @results ||= model.results.map do |result|
            category = categories.detect { |c| c.id.to_s == result['_id'] }
            OpenStruct.new({ category: category }.merge(result))
          end
        end

        def categories
          @categories ||= Catalog::Category.any_in(
            id: model.results.map { |r| r['_id'] }
          ).to_a
        end
      end
    end
  end
end
