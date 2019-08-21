module Workarea
  module Storefront
    class PageViewModel < ApplicationViewModel
      include DisplayContent

      def breadcrumbs
        @breadcrumbs ||= Navigation::Breadcrumbs.new(model)
      end
    end
  end
end
