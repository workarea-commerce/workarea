require 'test_helper'

module Workarea
  module Storefront
    class HostIntegrationTest < Workarea::IntegrationTest
      setup :set_host
      teardown :teardown_revert_host

      def set_host
        @current = Workarea.config.host
        @current_enforce = Workarea.config.enforce_host

        Workarea.config.host = 'www.bar.com'
        Workarea.config.enforce_host = true
      end

      def teardown_revert_host
        Workarea.config.host = @current
        Workarea.config.enforce_host = @current_enforce
      end

      def test_redirects_if_the_request_host_does_not_match_the_configured_host
        host! 'www.foo.com'
        get storefront.root_path

        assert(response.redirect?)
        assert_equal(301, response.status)
        assert_equal("http://www.bar.com#{storefront.root_path}", response.location)
      end
    end
  end
end
