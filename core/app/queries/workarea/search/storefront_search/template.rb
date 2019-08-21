module Workarea
  module Search
    class StorefrontSearch
      class Template
        include Middleware

        def call(response)
          if response.total > 0 || response.has_filters?
            yield
          else
            response.template = 'no_results'
          end
        end
      end
    end
  end
end
