require 'test_helper'

module Workarea
  module Storefront
    class HealthCheckIntegrationTest < Workarea::IntegrationTest
      def test_health_check
        get storefront.health_check_path

        assert_equal 'ok', response.body
      end
    end
  end
end
