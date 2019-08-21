require 'test_helper'

module Workarea
  module Admin
    class RedirectsIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_creates_a_redirect
        post admin.navigation_redirects_path,
          params: { redirect: { path: '/foo', destination: '/bar' } }

        assert_equal(1, Navigation::Redirect.count)

        redirect = Navigation::Redirect.first
        assert_equal('/foo', redirect.path)
        assert_equal('/bar', redirect.destination)
      end

      def test_deletes_a_redirect
        redirect = create_redirect
        delete admin.navigation_redirect_path(redirect)
        assert(Navigation::Redirect.empty?)
      end
    end
  end
end
