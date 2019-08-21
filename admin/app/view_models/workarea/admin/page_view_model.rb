module Workarea
  module Admin
    class PageViewModel < ApplicationViewModel
      include CommentableViewModel
      include ContentableViewModel

      def timeline
        @timeline ||= TimelineViewModel.new(model)
      end

      def breadcrumbs
        @breadcrumbs ||= Navigation::Breadcrumbs.new(model)
      end
    end
  end
end
