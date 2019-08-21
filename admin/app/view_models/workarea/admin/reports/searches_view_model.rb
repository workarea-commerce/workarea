module Workarea
  module Admin
    module Reports
      class SearchesViewModel < ApplicationViewModel
        def results
          @results ||= model.results.map { |result| OpenStruct.new(result) }
        end
      end
    end
  end
end
