module Workarea
  module Admin
    class CommentViewModel < ApplicationViewModel
      def author
        return @author if defined?(@author)

        @author = if model = User.where(id: author_id).first
                    UserViewModel.new(model)
                  end
      end

      def author_name
        return '' unless author.present?
        author.name
      end
    end
  end
end
