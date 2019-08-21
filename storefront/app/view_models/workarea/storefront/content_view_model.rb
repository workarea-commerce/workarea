module Workarea
  module Storefront
    class ContentViewModel < ApplicationViewModel
      include DisplayContent

      def content
        model
      end
    end
  end
end
