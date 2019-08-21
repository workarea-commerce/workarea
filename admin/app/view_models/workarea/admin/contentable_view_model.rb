module Workarea
  module Admin
    module ContentableViewModel
      def content
        @content ||= ContentViewModel.new(Content.for(model), options)
      end
    end
  end
end
