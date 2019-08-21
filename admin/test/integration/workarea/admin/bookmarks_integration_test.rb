require 'test_helper'

module Workarea
  module Admin
    class BookmarksIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_creation
        assert_difference 'User::AdminBookmark.count', 1 do
          post admin.bookmarks_path,
            params: {
              bookmark: { name: 'Products', path: '/admin/catalog_products' }
            }
        end
      end

      def test_deletion
        bookmark = User::AdminBookmark.create!(
          user: User.first,
          name: 'Products',
          path: '/admin/catalog_products'
        )

        delete admin.bookmark_path(bookmark)
        assert_equal(0, User::AdminBookmark.count)
      end
    end
  end
end
