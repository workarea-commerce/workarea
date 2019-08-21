module Workarea
  module Search
    class StorefrontSearch
      class ProductAutoRedirect
        include Middleware

        def call(response)
          if !response.has_filters? && response.total == 1
            response.redirect = product_path(
              response.query.results.first[:model]
            )
          else
            yield
          end
        end
      end
    end
  end
end
