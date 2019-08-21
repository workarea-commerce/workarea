module Workarea
  module Admin
    module Reports
      class SalesByTrafficReferrerViewModel < ApplicationViewModel
        def results
          @results ||= model.results.map do |result|
            processed = {
              medium: result['_id']['medium']&.titleize,
              source: result['_id']['source']&.titleize
            }.merge(result)

            OpenStruct.new(processed)
          end
        end
      end
    end
  end
end
