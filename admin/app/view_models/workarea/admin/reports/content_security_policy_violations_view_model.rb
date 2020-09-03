module Workarea
  module Admin
    module Reports
      class ContentSecurityPolicyViolationsViewModel < ApplicationViewModel
        def results
          @results ||= model.results.map do |result|
            OpenStruct.new(result)
          end
        end
      end
    end
  end
end
