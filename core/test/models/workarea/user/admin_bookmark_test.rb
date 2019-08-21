require 'test_helper'

module Workarea
  class User
    class AdminBookmarkTest < TestCase
      setup :set_user

      def set_user
        @user = create_user
      end

      def test_bookmarked
        refute(AdminBookmark.bookmarked?(@user, '/foo'))

        create_admin_bookmark(user: @user, path: '/foo')

        assert(AdminBookmark.bookmarked?(@user, '/foo'))
        assert(AdminBookmark.bookmarked?(@user, 'foo'))
      end

      def test_sanitized_path
        bookmark = create_admin_bookmark(user: @user, path: 'foo')
        assert_equal('/foo', bookmark.path)

        bookmark = create_admin_bookmark(user: @user, path: '/foo')
        assert_equal('/foo', bookmark.path)

        bookmark = create_admin_bookmark(user: @user, path: '/foo?')
        assert_equal('/foo', bookmark.path)

        bookmark = create_admin_bookmark(user: @user, path: '/foo?bar=baz')
        assert_equal('/foo?bar=baz', bookmark.path)

        bookmark = create_admin_bookmark(user: @user, path: 'http://malicious.com/foo?')
        assert_equal('/foo', bookmark.path)
      end
    end
  end
end
