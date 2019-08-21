module Workarea
  module Admin
    module Reports
      class SalesByTenderViewModel < ApplicationViewModel
        def results
          @results ||= model.results.map do |result|
            OpenStruct.new(result.merge(name: result['_id'].titleize))
          end
        end
      end
    end
  end
end
