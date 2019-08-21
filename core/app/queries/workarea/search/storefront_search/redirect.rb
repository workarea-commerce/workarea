module Workarea
  module Search
    class StorefrontSearch
      class Redirect
        include Middleware

        def call(response)
          if customization.redirect?
            response.redirect = customization.redirect
          else
            yield
          end
        end
      end
    end
  end
end
