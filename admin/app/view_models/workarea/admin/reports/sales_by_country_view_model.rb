module Workarea
  module Admin
    module Reports
      class SalesByCountryViewModel < ApplicationViewModel
        def results
          @results ||= model.results.map do |result|
            name = Country[result['_id']]&.name
            OpenStruct.new({ name: name }.merge(result))
          end
        end
      end
    end
  end
end
