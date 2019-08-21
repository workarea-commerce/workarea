module Workarea
  module Admin
    module BookmarksHelper
      def bookmarks
        @bookmarks ||= User::AdminBookmark
                        .by_user(current_user)
                        .limit(Workarea.config.max_admin_bookmarks)
      end

      def bookmarked?
        User::AdminBookmark.bookmarked?(current_user, request.fullpath)
      end
    end
  end
end
