# frozen_string_literal: true
module Workarea
  module Admin
    class AssetViewModel < ApplicationViewModel
      include CommentableViewModel

      def timeline
        @timeline ||= TimelineViewModel.new(model)
      end
    end
  end
end
