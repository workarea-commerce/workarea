module Workarea
  module Admin
    module Reports
      class CustomersViewModel < ApplicationViewModel
        def results
          @results ||= model.results.map do |result|
            user = users[result['_id']]
            OpenStruct.new({ user: user }.merge(result))
          end
        end

        def users
          @users ||= User
            .any_in(email: model.results.map { |r| r['_id'] })
            .each_with_object({}) { |u, r| r[u.email] = u }
        end
      end
    end
  end
end
